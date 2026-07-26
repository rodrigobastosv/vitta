# Meal suggestions — setup

The "suggest a meal" action on `AddFoodPage` (the sparkle icon in the app bar) sends the day's **remaining
macros** and **what has already been logged** to the `suggest-meals` Supabase Edge Function, which asks
Claude for a few meal options that fit the gap and returns each one's items with per-100g macros. The app
then lets the user pick an option, tweak the amounts, untick anything they don't want, and log it to the day.

**The function is not deployed from this repo** — it lives in the Supabase project it is deployed to, and is
edited there (**Dashboard → Edge Functions**); there is no `supabase/functions/` directory and no deploy step
in CI. Its source is reproduced below so the prompt and schema exist somewhere in version control rather than
only in a dashboard, but the deployed copy is the one that runs: after editing it there, paste it back here.
The Anthropic API key cannot live in this repo at all.

**Until the function is deployed and the key is set, suggesting fails** with "Failed to suggest meals" — the
rest of the diet feature is unaffected, since only this action depends on it.

This follows the same split as the [meal scan](meal-scan-setup.md) and the
[nutrition label scan](nutrition-scan-setup.md) — no server code is deployed from this repo — except that
those two runbooks describe their function rather than carrying it, so their prompts exist nowhere but the
dashboard. Only the client half is *wired* here:
`SupabaseFunction.suggestMeals` names the deployed function
(`lib/app/core/services/supabase/supabase_function.dart`) and `SupabaseMealSuggestionDataSource` calls it.

## One-time setup

### 1. Anthropic API key

Create one at [console.anthropic.com](https://console.anthropic.com) → **API keys**. If either scan is
already set up, the same `ANTHROPIC_API_KEY` secret is reused — this function only needs its own deployment.

### 2. Set it as a Supabase secret

The key must never reach the app — an API key shipped in a mobile binary is extractable by anyone who
downloads it. In the dashboard: **Project Settings → Edge Functions → Secrets**, as `ANTHROPIC_API_KEY`.

### 3. Gate it behind premium

Meal suggestions are a premium feature, and **the function is the gate — the app's lock is only UX**
(see [premium setup](premium-setup.md)). Copy the entitlement check from `scan-meal` verbatim: read the
caller's id from the **verified JWT** (never the request body), look up `subscriptions`, and return **402**
before calling Anthropic if the caller is not entitled. The two rules that check duplicates are
`PremiumStatus.isActive`'s: an `active` row whose `expires_at` has passed is **not** entitled, and
`cancelled` **is** entitled until it expires. The app maps a 402 to `PremiumRequiredError` and opens the
paywall; anything else is a plain error toast.

### 4. Create the function

In the dashboard: **Edge Functions → Deploy a new function**, named exactly `suggest-meals` — the name is
what `SupabaseFunction.suggestMeals` resolves to, so it has to match.

#### Request

`MealSuggestionRequest.toJson()` sends:

```json
{
  "mealType": "lunch",
  "languageCode": "pt",
  "goal":      {"calories": 2135, "protein": 150, "carbs": 250, "fat": 65, "fiber": 30},
  "consumed":  {"calories": 620,  "protein": 38,  "carbs": 70,  "fat": 18, "fiber": 6},
  "remaining": {"calories": 1515, "protein": 112, "carbs": 180, "fat": 47, "fiber": 24},
  "loggedFoods": [
    {"name": "Aveia em flocos", "mealType": "breakfast", "quantityGrams": 60},
    {"name": "Banana", "mealType": "breakfast", "quantityGrams": 120}
  ]
}
```

- `mealType` is one of `breakfast` / `lunch` / `dinner` / `snack` — the meal the user asked about.
- `remaining` is `goal − consumed` and **can be negative**: the user is already over on that macro, which is
  something the suggestion has to work around rather than ignore.
- `loggedFoods` is empty when nothing has been logged yet. That is the issue's "or it can suggest a one-time
  meal only" case, and it needs no separate branch — the gap is simply the whole goal.
- `languageCode` is the user's app language (`en` or `pt`). **Every name and summary must be written in it**,
  because they are shown as-is and become shared-catalog `foods` rows.

#### Response

```json
{
  "meals": [
    {
      "name": "Frango grelhado com arroz e brócolis",
      "summary": "Rica em proteína, pronta em 20 minutos",
      "items": [
        {
          "name": "Peito de frango grelhado",
          "suggestedGrams": 180,
          "caloriesPer100g": 165,
          "proteinPer100g": 31,
          "carbsPer100g": 0,
          "fatPer100g": 3.6,
          "fiberPer100g": 0
        }
      ]
    }
  ]
}
```

Pin **`claude-opus-4-8` with structured outputs** (`output_config.format` + a JSON schema), which is what
guarantees the response parses into `MealSuggestions` with no defensive parsing on the Dart side.

#### What the prompt must get right

- **Return two or three alternative options, not a day's worth of meals.** The user is adding *one* meal and
  picks one card; three meals meant to be eaten together would each be logged as if it were the whole answer.
- **Each option should close as much of the gap as one sensible meal can** — not all of it. If `remaining`
  is a whole day's calories because nothing is logged yet, suggest a normal-sized meal for `mealType`, not a
  2000 kcal plate.
- **Respect what is already over.** A negative `remaining.carbs` means suggest low-carb options; it does not
  mean subtract carbs from the meal.
- **Do not repeat what is in `loggedFoods`.** Suggesting the chicken and rice the user already ate today is
  the fastest way to make the feature feel like it did not read the request.
- **Macros are per 100 g, in grams** — the same base unit the whole diet feature stores. `suggestedGrams` is
  the portion for that item; the app multiplies the two. A missing number defaults to 0 on the Dart side
  (`SuggestedMealItem.fromMap`), so omitting a field is safe but understates the item — prefer a best
  estimate, and prefer well-known whole foods whose macros you are confident about.
- **Keep each option to a handful of items** (2–5). Every included item becomes a `foods` row and a
  `food_logs` row.
- **Return an empty `meals` list rather than inventing something** when the request cannot be answered
  sensibly. The app surfaces that as "no meal to suggest" and invites another try, which is a better failure
  than a hallucinated plate — the same "return null rather than guess" rule the scan prompts follow. Every
  logged item joins the shared catalog.

#### The implementation

Paste this as the function's `index.ts`. It is the whole function — JWT verification, the premium gate, the
Anthropic call, and the response. Nothing in it is a secret: the two keys it uses come from the environment
(`ANTHROPIC_API_KEY` is the secret you set in step 2; `SUPABASE_URL`/`SUPABASE_ANON_KEY` are injected by the
platform).

```ts
import Anthropic from "npm:@anthropic-ai/sdk";
import { createClient } from "npm:@supabase/supabase-js@2";

// Mirrors PremiumStatus.isActive on the Dart side: `cancelled` still entitles
// until it lapses (auto-renew off is not a refund), and an `active` row whose
// expires_at has passed does not. If one moves, move the other.
const ENTITLING_STATUSES = ["active", "cancelled", "in_grace_period"];

const MODEL = "claude-opus-5";

// Structured outputs reject numeric/length constraints (no minimum, maxItems,
// minLength), and every object needs additionalProperties:false with every key
// required. Counts and ranges therefore live in the prompt, not here.
const SUGGESTIONS_SCHEMA = {
  type: "object",
  properties: {
    meals: {
      type: "array",
      items: {
        type: "object",
        properties: {
          name: { type: "string", description: "The meal's name, in the requested language." },
          summary: { type: "string", description: "One short line on why it fits, in the requested language." },
          items: {
            type: "array",
            items: {
              type: "object",
              properties: {
                name: { type: "string", description: "The food's name, in the requested language." },
                suggestedGrams: { type: "number", description: "Portion of this item, in grams." },
                caloriesPer100g: { type: "number" },
                proteinPer100g: { type: "number" },
                carbsPer100g: { type: "number" },
                fatPer100g: { type: "number" },
                fiberPer100g: { type: "number" },
              },
              required: [
                "name",
                "suggestedGrams",
                "caloriesPer100g",
                "proteinPer100g",
                "carbsPer100g",
                "fatPer100g",
                "fiberPer100g",
              ],
              additionalProperties: false,
            },
          },
        },
        required: ["name", "summary", "items"],
        additionalProperties: false,
      },
    },
  },
  required: ["meals"],
  additionalProperties: false,
};

const SYSTEM_PROMPT = `You suggest meals that fit what is left of someone's daily macro targets.

You receive the day's goal, what has been consumed, what remains (goal minus consumed), the meal being
planned, the foods already logged today, and a language code.

Rules:
- Return two or three ALTERNATIVE options. The user picks ONE and logs it. Never return meals that are
  meant to be eaten together, and never return a day's worth of eating.
- Each option should close as much of the remaining gap as one sensible meal of this type reasonably can -
  not all of it. If nothing has been logged yet the remaining figures are a whole day; still suggest a
  normal-sized breakfast/lunch/dinner/snack, not a 2000 kcal plate.
- A NEGATIVE remaining figure means the person is already over on that macro. Suggest options that are low
  in it. Never try to subtract it.
- Do not suggest anything already in loggedFoods, and do not repeat a food across the options.
- Keep each option to 2-5 items. Every item becomes a row in a shared food catalog and a diary entry.
- Macros are PER 100 g, in grams. suggestedGrams is the portion of that item. The app multiplies the two,
  so the two figures must be independently correct. Prefer well-known whole foods whose macros you are
  confident about; give your best estimate rather than 0 for a macro you are unsure of.
- Write every name and summary in the language named by languageCode ("pt" is Brazilian Portuguese, "en" is
  English). These strings are shown as-is and become shared catalog rows.
- If you cannot answer sensibly, return an empty meals array rather than inventing a plate.`;

const json = (body: unknown, status: number) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

const isEntitled = (subscription: { status: string; expires_at: string | null } | null) => {
  if (subscription === null || !ENTITLING_STATUSES.includes(subscription.status)) {
    return false;
  }
  return subscription.expires_at === null || new Date(subscription.expires_at) > new Date();
};

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const authorization = request.headers.get("Authorization");
  if (authorization === null) {
    return json({ error: "unauthorized" }, 401);
  }

  // The caller's own client: the uid comes from the verified JWT, never from
  // the request body, and subscriptions' RLS scopes the read to that uid. No
  // service-role key is needed - or wanted - in this function.
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authorization } } },
  );

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return json({ error: "unauthorized" }, 401);
  }

  const { data: subscription } = await supabase
    .from("subscriptions")
    .select("status, expires_at")
    .eq("user_id", user.id)
    .maybeSingle();

  // 402 before Anthropic is charged. The app maps this to PremiumRequiredError
  // and opens the paywall; its own lock is only UX.
  if (!isEntitled(subscription)) {
    return json({ error: "premium_required" }, 402);
  }

  const body = await request.json();

  const anthropic = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY")! });

  const message = await anthropic.beta.messages.create({
    model: MODEL,
    max_tokens: 16000,
    // Delete these two lines if your account rejects the beta: they re-serve a
    // safety-classifier decline on another model instead of failing, which for
    // a meal prompt is close to unreachable insurance.
    betas: ["server-side-fallback-2026-07-01"],
    fallbacks: "default",
    output_config: {
      effort: "medium",
      format: { type: "json_schema", schema: SUGGESTIONS_SCHEMA },
    },
    system: SYSTEM_PROMPT,
    messages: [{ role: "user", content: JSON.stringify(body) }],
  });

  if (message.stop_reason === "refusal") {
    return json({ error: "refused" }, 502);
  }

  const text = message.content.find((block) => block.type === "text");
  if (!text || text.type !== "text") {
    return json({ error: "empty_response" }, 502);
  }

  return json(JSON.parse(text.text), 200);
});
```

Four things in it are load-bearing and worth keeping if you edit it:

- **The uid comes from `auth.getUser()`, never from the request body.** Reading it from the body would let
  any caller ask about any account. It is also why the function needs no service-role key: `subscriptions`'
  select policy already scopes the read to `auth.uid()`.
- **The 402 is returned before Anthropic is called**, so an unentitled caller costs nothing.
- **`ENTITLING_STATUSES` and the expiry check duplicate `PremiumStatus.isActive`** on the Dart side. That
  duplication is deliberate (the client lock is UX, the function is the gate), but it means a change to one
  has to be made in the other.
- **The schema carries no counts or ranges.** Structured outputs reject `minimum`, `maxItems`, `minLength`
  and friends, so "two or three options" and "2-5 items" are stated in the prompt instead — and are
  therefore guidance, not a guarantee. The app tolerates any count.

`claude-opus-5` thinks by default, which is what makes it fit macros to a gap rather than pattern-matching a
meal; `effort: "medium"` is the cost/latency dial. Raise it to `high` if the suggestions feel careless, drop
it to `low` if they are fine and you want them faster.

The function requires a valid JWT by default, which the app's anonymous session already provides — no extra
auth wiring needed beyond the premium check in step 3.

### 5. Verify

```sh
curl -X POST 'https://<your-project-ref>.supabase.co/functions/v1/suggest-meals' \
  -H "Authorization: Bearer <a signed-in user's access token>" \
  -H 'Content-Type: application/json' \
  -d '{
        "mealType": "lunch",
        "languageCode": "en",
        "goal":      {"calories": 2135, "protein": 150, "carbs": 250, "fat": 65, "fiber": 30},
        "consumed":  {"calories": 0, "protein": 0, "carbs": 0, "fat": 0, "fiber": 0},
        "remaining": {"calories": 2135, "protein": 150, "carbs": 250, "fat": 65, "fiber": 30},
        "loggedFoods": []
      }'
```

An entitled caller gets two or three options; an unentitled one gets **402** and spends nothing on Anthropic.

## Cost

Each request is a short JSON prompt plus a short JSON response — roughly $0.01–0.03 on `claude-opus-4-8` at
current pricing, per tap of the "Suggest meals" button. Nothing is requested when the page merely opens: the
day's gap is read locally and from Supabase, and the model is only asked once the user presses the button.

## Changing the function

Edit it in the dashboard (**Edge Functions → `suggest-meals`**) and deploy from there. There is no copy in
this repo to keep in sync — that is the point, but it also means the dashboard is the only place the current
prompt and schema exist. Nothing on the Dart side needs to change unless the response shape does, in which
case `MealSuggestions.fromMap` / `SuggestedMeal.fromMap` / `SuggestedMealItem.fromMap` is what has to move
with it.
