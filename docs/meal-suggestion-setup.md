# Meal suggestions — setup

The "suggest a meal" action on `AddFoodPage` (the sparkle icon in the app bar) sends the day's **remaining
macros** and **what has already been logged** to the `suggest-meals` Supabase Edge Function, which asks
Claude for a few meal options that fit the gap and returns each one's items with per-100g macros. The app
then lets the user pick an option, tweak the amounts, untick anything they don't want, and log it to the day.

**The function's source is deliberately not in this repo** — it lives only in the Supabase project it is
deployed to, and is edited there (**Dashboard → Edge Functions**). Nor can its Anthropic API key live here.
**Until the function is deployed and the key is set, suggesting fails** with "Failed to suggest meals" — the
rest of the diet feature is unaffected, since only this action depends on it.

This is the same client-half-only split the [meal scan](meal-scan-setup.md) and the
[nutrition label scan](nutrition-scan-setup.md) use. Only the client half is tracked here:
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
