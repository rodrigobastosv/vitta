# Nutrition label scan — setup

The "scan nutrition label" action on `CustomFoodPage` sends the photo to the `scan-nutrition-label`
Supabase Edge Function, which asks Claude to read it and returns the macros per 100g.

**The function's source is deliberately not in this repo** — it lives only in the Supabase project it is
deployed to, and is edited there (**Dashboard → Edge Functions**). Nor can its Anthropic API key live
here. **Until the function is deployed and the key is set, scanning fails** with "Failed to read nutrition
label" — the rest of the custom-food form still works, since the scan only pre-fills fields the user can
always type by hand.

Only the client half is tracked here: `SupabaseFunction.scanNutritionLabel` names the deployed function
(`lib/app/core/services/supabase/supabase_function.dart`) and `SupabaseNutritionScanDataSource` calls it.

## One-time setup

### 1. Get an Anthropic API key

Create one at [console.anthropic.com](https://console.anthropic.com) → **API keys**. The key is billed per
use; see cost below.

### 2. Set it as a Supabase secret

The key must never reach the app — an API key shipped in a mobile binary is extractable by anyone who
downloads it. The Edge Function is the whole reason this is safe: the key stays server-side, and the app
only ever calls the function.

In the dashboard: **Project Settings → Edge Functions → Secrets**, as `ANTHROPIC_API_KEY`.

### 3. Create the function

In the dashboard: **Edge Functions → Deploy a new function**, named exactly `scan-nutrition-label` — the
name is what `SupabaseFunction.scanNutritionLabel` resolves to, so it has to match.

It takes `{"imageBase64": "...", "fileExtension": "jpg"}` and returns the five nutrients per 100g. It pins
`claude-opus-4-8` with structured outputs (`output_config.format` + a JSON schema), which is what
guarantees the response parses into `ScannedNutritionFacts` with no defensive parsing on the Dart side.
Every nutrient is nullable and the prompt says to return null rather than guess: a wrong macro silently
poisons a shared catalog row, so a blank field the user fills in is the better failure.

The function requires a valid JWT by default, which the app's anonymous session already provides — no extra
auth wiring needed.

### 4. Verify

```sh
curl -X POST 'https://<your-project-ref>.supabase.co/functions/v1/scan-nutrition-label' \
  -H "Authorization: Bearer <SUPABASE_PUBLISHABLE_KEY>" \
  -H 'Content-Type: application/json' \
  -d "{\"imageBase64\":\"$(base64 -i label.jpg)\",\"fileExtension\":\"jpg\"}"
```

A readable label returns the five nutrients; anything that isn't a legible nutrition label returns `null`
for all five, which the app surfaces as "couldn't read the label".

## Cost

Each scan is one image plus a short JSON response — roughly $0.01–0.02 on `claude-opus-4-8` at current
pricing. That is per scan, not per user, and only when someone actually taps scan rather than typing the
values. If scan volume grows enough for that to matter, the model is a one-line change in the function's
dashboard editor.

## Changing the function

Edit it in the dashboard (**Edge Functions → `scan-nutrition-label`**) and deploy from there. There is no
copy in this repo to keep in sync — that is the point, but it also means the dashboard is the only place
the current prompt and schema exist. Nothing on the Dart side needs to change unless the response shape
does, in which case `ScannedNutritionFacts.fromMap` is what has to move with it.
