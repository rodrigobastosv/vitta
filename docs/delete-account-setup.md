# Delete account — setup

The "Delete account" option on `ProfilePage` (shown only to a signed-in, non-anonymous user) permanently
deletes that user and, through the database's own foreign keys, all of their data. It calls the
`delete-account` Supabase Edge Function.

**The function's source is deliberately not in this repo** — it lives only in the Supabase project it is
deployed to, and is edited there (**Dashboard → Edge Functions**), the same split the `scan-nutrition-label`
function uses. **Until the function is deployed, deletion fails** with "Failed to delete account".

Only the client half is tracked here: `SupabaseFunction.deleteAccount` names the deployed function
(`lib/app/core/services/supabase/supabase_function.dart`), `SupabaseAuthDataSource.deleteAccount` calls it,
and `DeleteAccountUseCase` follows it with a fresh anonymous sign-in so the app stays usable afterwards.

## Why an Edge Function

Deleting an `auth.users` row requires the **service-role key** (`auth.admin.deleteUser`), which the client
must never hold — a service-role key shipped in a mobile binary is extractable by anyone who downloads the
app. The function is the whole reason this is safe: the key stays server-side, the app only calls the
function, and the function verifies the caller's JWT (the anonymous session already supplies one) so a user
can only ever delete **themselves**.

## Why deleting the auth user is enough

Every user-scoped table references `auth.users (id) on delete cascade` (see `supabase/schema.sql`), so
deleting the auth user cascades to `food_logs`, `water_logs`, `sleep_logs`, `body_weight_logs`, `recipes`
(→ `recipe_ingredients`), `food_favorites`, `workouts` (→ `workout_exercises` → `workout_sets`), `routines`
(→ `routine_exercises`), and the user's own `foods`/`exercises` catalog rows (which have the user's
`user_id`). The bulk-imported catalog rows have a null `user_id`, so they are untouched. There is no
separate delete statement to keep in sync — the cascade is the source of truth.

## One-time setup

### 1. Create the function

In the dashboard: **Edge Functions → Deploy a new function**, named exactly `delete-account` — the name is
what `SupabaseFunction.deleteAccount` resolves to, so it has to match.

It takes an empty body, reads the caller's id from the verified JWT, and calls
`supabaseAdmin.auth.admin.deleteUser(userId)` with a client built from the service-role key. It must **never
take a user id from the request body** — that would let any caller delete any account; the id comes only
from the JWT.

### 2. Set the service-role key as a secret

The Edge Function needs the project's service-role key. `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are
provided to deployed functions automatically by Supabase, so no secret usually needs setting by hand — if
your function reads them under different names, add those in **Project Settings → Edge Functions → Secrets**.

### 3. Verify

```sh
curl -X POST 'https://<your-project-ref>.supabase.co/functions/v1/delete-account' \
  -H "Authorization: Bearer <a real user access token>" \
  -H 'Content-Type: application/json' \
  -d '{}'
```

Use a throwaway account's token — this actually deletes it. A success response means the auth user and every
cascade-linked row are gone.

## Client behaviour after deletion

`DeleteAccountUseCase` runs the function, then signs out and signs back in **anonymously**, so the app is
left on a clean, empty guest session rather than a dead one — the same "reset to a fresh anonymous account"
shape `SignOutUseCase` uses. The profile page confirms first with `DeleteAccountDialog`, whose copy states
the action can't be undone.

## What is not deleted

Storage objects (uploaded avatars under the user's id prefix, and any food/exercise photos they contributed
to the shared catalog) are not removed by the cascade. Catalog photos are deliberately left — they belong to
shared rows other users may still reference. If per-user avatar cleanup is wanted, have the function also
delete the `avatars/<userId>/` prefix before deleting the user.
