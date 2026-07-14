# Nutrition label scan — setup

The "scan nutrition label" action on `CustomFoodPage` sends the photo to a Supabase Edge Function
(`supabase/functions/scan-nutrition-label/`), which asks Claude to read it and returns the macros per 100g.

None of this can live in the repo: the function has to be deployed to your Supabase project, and the
Anthropic API key has to be set as a secret there. **Until both steps are done, scanning fails** with
"Failed to read nutrition label" — the rest of the custom-food form still works, since the scan only
pre-fills fields the user can always type by hand.

## One-time setup

### 1. Install the Supabase CLI

`supabase` is a standalone binary — it is not an npm dependency of this project and does not come with
`flutter pub get`. Deploying a function is the only way to ship one, so this step is required.

```sh
brew install supabase/tap/supabase
supabase login
```

`login` opens a browser and stores a token, so the deploy in step 3 can talk to your project. The
`--project-ref` used below is the ID in your project's dashboard URL
(`https://supabase.com/dashboard/project/<project-ref>`).

### 2. Get an Anthropic API key

Create one at [console.anthropic.com](https://console.anthropic.com) → **API keys**. The key is billed per
use; see cost below.

### 3. Set it as a Supabase secret

The key must never reach the app — an API key shipped in a mobile binary is extractable by anyone who
downloads it. The Edge Function is the whole reason this is safe: the key stays server-side, and the app
only ever calls the function.

```sh
supabase secrets set ANTHROPIC_API_KEY=sk-ant-... --project-ref <your-project-ref>
```

You can also do this without the CLI, in the dashboard: **Project Settings → Edge Functions → Secrets**.
Deploying (step 4) has no equivalent dashboard path for a function that lives in this repo, so the CLI is
needed either way.

### 4. Deploy the function

```sh
supabase functions deploy scan-nutrition-label --project-ref <your-project-ref>
```

The function requires a valid JWT by default, which the app's anonymous session already provides — no extra
auth wiring needed.

### 5. Verify

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
values. If scan volume grows enough for that to matter, the model is a one-line change in
`supabase/functions/scan-nutrition-label/index.ts`.

## Local development

```sh
supabase functions serve scan-nutrition-label --env-file supabase/functions/.env
```

with `ANTHROPIC_API_KEY=sk-ant-...` in that env file (gitignore it — it is a real credential).
