# Meal scan — setup

The "scan a meal" action on `DietPage` (the camera icon in the app bar) sends a photo of a plate to the
`scan-meal` Supabase Edge Function, which asks Claude to identify each food item, estimate its portion in
grams, and return per-100g macros for each. The app then lets the user review the detected items, tweak the
amounts, pick a meal type, and log them to the day.

**The function's source is deliberately not in this repo** — it lives only in the Supabase project it is
deployed to, and is edited there (**Dashboard → Edge Functions**). Nor can its Anthropic API key live here.
**Until the function is deployed and the key is set, scanning fails** with "Failed to scan meal" — the rest
of the diet feature is unaffected, since only the scan action depends on it.

This is the same client-half-only split the [nutrition label scan](nutrition-scan-setup.md) uses. Only the
client half is tracked here: `SupabaseFunction.scanMeal` names the deployed function
(`lib/app/core/services/supabase/supabase_function.dart`) and `SupabaseMealScanDataSource` calls it.

## One-time setup

### 1. Get an Anthropic API key

Create one at [console.anthropic.com](https://console.anthropic.com) → **API keys**. The key is billed per
use; see cost below. If the nutrition-label scan is already set up, the same `ANTHROPIC_API_KEY` secret is
reused — this function only needs its own deployment.

### 2. Set it as a Supabase secret

The key must never reach the app — an API key shipped in a mobile binary is extractable by anyone who
downloads it. The Edge Function is the whole reason this is safe: the key stays server-side, and the app
only ever calls the function.

In the dashboard: **Project Settings → Edge Functions → Secrets**, as `ANTHROPIC_API_KEY`.

### 3. Create the function

In the dashboard: **Edge Functions → Deploy a new function**, named exactly `scan-meal` — the name is what
`SupabaseFunction.scanMeal` resolves to, so it has to match.

It takes `{"imageBase64": "...", "fileExtension": "jpg"}` and returns a list of items:

```json
{
  "items": [
    {
      "name": "Grilled chicken breast",
      "estimatedGrams": 150,
      "caloriesPer100g": 165,
      "proteinPer100g": 31,
      "carbsPer100g": 0,
      "fatPer100g": 3.6,
      "fiberPer100g": 0
    }
  ]
}
```

It should pin `claude-opus-4-8` with structured outputs (`output_config.format` + a JSON schema), which is
what guarantees the response parses into `ScannedMeal` with no defensive parsing on the Dart side. Two
things the prompt/schema must get right, mirroring the label scanner:

- **Macros are per 100 g, in grams** — the same base unit the whole diet feature stores. `estimatedGrams`
  is the portion actually on the plate; the app multiplies the two. A missing number defaults to 0 on the
  Dart side (`ScannedMealItem.fromMap`), so returning 0 (or omitting a field) is safe but understates the
  item — prefer a best estimate.
- **Return an empty `items` list rather than guessing** when the photo is not a meal (a label, a receipt, a
  landscape). The app surfaces an empty list as "no food detected" and invites another photo, which is a
  better failure than logging a hallucinated plate — the same reasoning the label scanner's null-not-guess
  rule follows. Every logged item becomes a shared-catalog `foods` row.

The function requires a valid JWT by default, which the app's anonymous session already provides — no extra
auth wiring needed.

### 4. Verify

```sh
curl -X POST 'https://<your-project-ref>.supabase.co/functions/v1/scan-meal' \
  -H "Authorization: Bearer <SUPABASE_PUBLISHABLE_KEY>" \
  -H 'Content-Type: application/json' \
  -d "{\"imageBase64\":\"$(base64 -i plate.jpg)\",\"fileExtension\":\"jpg\"}"
```

A photo of a meal returns one entry per detected item; anything that isn't a meal returns `{"items": []}`,
which the app surfaces as "no food detected".

## Cost

Each scan is one image plus a short JSON response — roughly $0.01–0.02 on `claude-opus-4-8` at current
pricing. That is per scan, not per user, and only when someone actually taps scan. If scan volume grows
enough for that to matter, the model is a one-line change in the function's dashboard editor.

## Changing the function

Edit it in the dashboard (**Edge Functions → `scan-meal`**) and deploy from there. There is no copy in this
repo to keep in sync — that is the point, but it also means the dashboard is the only place the current
prompt and schema exist. Nothing on the Dart side needs to change unless the response shape does, in which
case `ScannedMeal.fromMap` / `ScannedMealItem.fromMap` is what has to move with it.
