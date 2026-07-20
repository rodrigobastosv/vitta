# Premium — setup

The two AI scans — the [meal photo scan](meal-scan-setup.md) and the [nutrition label
scan](nutrition-scan-setup.md) — each cost roughly $0.01–0.02 per call in Anthropic usage. Everything else in
Vitta (food search, the catalog, recipes, water, sleep, body weight, workouts, reminders and every history
chart) has no marginal cost and stays free. This issue (#153) puts the two scans behind a premium
entitlement and — the part that actually matters — enforces it **in the Edge Functions**, not in the app.

**No store purchase flow exists yet.** This is the preparation half: the entitlement model, the server gate,
the client locks and the paywall screen all work today, and premium is granted by inserting a row by hand
(step 3 below). Wiring a real subscription is a follow-up, sketched at the end.

## Where entitlement lives, and why it is not `user_metadata`

The `subscriptions` table (`supabase/schema.sql`) holds one row per user: `product_id`, `status`,
`store`, `expires_at`.

`auth.users.user_metadata` — where `display_name` and `avatar_id` live — is **writable by the client**
through `auth.updateUser`, which `SupabaseAuthDataSource` already calls. An `is_premium` flag there could be
set by any user against themselves with one API call. The profile fields are safe there precisely because
nothing is gated on them.

So `subscriptions` has exactly one RLS policy, `for select`. **The absence of insert/update/delete policies
is the security property**: under RLS an operation with no matching policy is denied, so a row can only be
written with the service-role key, which bypasses RLS entirely. Do not "complete the set" by adding the
other three.

## Why the Edge Function is the gate

`MealScanAction` and `CustomFoodScanCard` show a lock and route to the paywall when the user is not
entitled. **That is UX, not enforcement** — it turns a paid tap into an explanation instead of a confusing
error. A modified client can skip it entirely.

What actually protects the Anthropic bill is step 2 below: each function reads the caller's id from the
**verified JWT** (never from the request body, or any caller could claim any id), looks up their
subscription with the service-role key, and returns **402** before calling Anthropic.

On the Dart side, a 402 becomes a `PremiumRequiredError` (`lib/app/core/error/premium_required_error.dart`)
rather than a generic `VTError`, so `MealScanCubit` / `CustomFoodCubit` open the paywall instead of showing
a failure toast. That is the safety net for a client whose local check went stale — a subscription that
lapsed while the app was open.

## One-time setup

### 1. Create the table

Run `supabase/schema.sql` in the SQL editor (it is safe to re-run in full). That creates `subscriptions`
with its select-only policy.

### 2. Add the gate to both Edge Functions

Both function sources live only in the Supabase dashboard (**Edge Functions → `scan-meal` / →
`scan-nutrition-label`**), per the split those two runbooks explain. Each gets a `premiumRefusal` helper and
one call to it as the first thing the handler does, **before** the body is parsed and long before Anthropic
is called.

**The lookup uses the caller's own JWT, not the service-role key.** `subscriptions`' RLS already scopes a
row to `auth.uid()`, so the query needs no `.eq('user_id', ...)` at all — Postgres decides whose row it is
from the verified token, and the user id never passes through the function's JavaScript where it could be
confused with something a caller supplied. That is both stronger than reading the id in JS and far less
privileged: a service-role client in a request handler is total database access, held for no reason here.

```ts
import { createClient } from "jsr:@supabase/supabase-js@2";

// cancelled still entitles until it lapses: the user turned off auto-renew, they
// did not ask for the rest of the period they paid for back. Mirrors
// SubscriptionStatus.entitles on the Dart side.
const ENTITLING_STATUSES = ["active", "in_grace_period", "cancelled"];

async function premiumRefusal(request: Request): Promise<Response | null> {
  const authorization = request.headers.get("Authorization");
  if (!authorization) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }

  const client = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authorization } } },
  );

  // No .eq('user_id', ...): subscriptions' RLS scopes this to auth.uid() itself.
  const { data: subscription, error } = await client
    .from("subscriptions")
    .select("status, expires_at")
    .maybeSingle();

  // A lookup that failed is not a refusal. Answering 402 here would tell a
  // paying user to pay again because the database hiccuped.
  if (error) {
    console.error("subscription lookup failed", error);
    return jsonResponse({ error: "Failed to verify subscription" }, 500);
  }

  // The expiry is checked alongside the status because the row is only corrected
  // when the store tells us. Mirrors PremiumStatus.isActive.
  const entitles = ENTITLING_STATUSES.includes(subscription?.status ?? "");
  const hasLapsed = subscription?.expires_at != null &&
    new Date(subscription.expires_at) <= new Date();

  return entitles && !hasLapsed ? null : jsonResponse({ error: "premium_required" }, 402);
}
```

`SUPABASE_URL` and `SUPABASE_ANON_KEY` are injected into every function automatically — they are not secrets
you have to set. `jsonResponse` is `scan-nutrition-label`'s existing helper; `scan-meal` has no such helper
and must spread its own `CORS_HEADERS` into each response instead.

Called as the first statement of the handler (after the OPTIONS/method check in `scan-meal`):

```ts
const refusal = await premiumRefusal(request);
if (refusal) {
  return refusal;
}
```

The two status/expiry rules are duplicated between here and Dart on purpose — the client copy drives what
is shown, this copy is what enforces. If one moves, move the other.

### 3. Grant yourself premium, for testing

```sql
insert into subscriptions (user_id, product_id, status, store)
values ('<your-auth-uid>', 'vitta_premium_monthly', 'active', 'manual')
on conflict (user_id) do update set status = 'active', updated_at = now();
```

Your uid is in **Authentication → Users**. `store = 'manual'` is what marks a row a human inserted rather
than one a store webhook wrote.

### 4. Verify

Restart the app. The diet app-bar camera icon and the custom-food scan card should lose their lock and both
scans should run. Then, **without restarting**, set the row's `status` to `'expired'` and trigger a scan
again: the function must return 402 and the app must open the paywall. That last step is the one that proves
the server is what is enforcing — the client still believes you are subscribed at that moment.

## Cost

The gate itself is free (one indexed primary-key lookup per scan). What it protects is the Anthropic spend
described in the two scan runbooks — roughly $0.01–0.02 per scan, per scan and not per user, which is
exactly why an unlimited free tier does not work.

## How store subscriptions work

Both Apple and Google require digital goods to be sold through their own in-app purchase systems (15–30%
commission). The shape is the same on both:

1. You define an **auto-renewable subscription product** with a product ID in App Store Connect / Play
   Console — price, duration, and optionally a free trial or introductory offer. Store-side free trials are
   why the app does not need to build its own.
2. The app fetches the available products, shows a paywall, and asks the store to start a purchase. The OS
   owns the payment sheet; you never see card details.
3. The store returns a **receipt / purchase token**. This is a claim, not proof — a jailbroken device can
   fabricate one.
4. Something trustworthy validates that token against Apple's App Store Server API or the Google Play
   Developer API, and records the resulting entitlement.
5. The store notifies you of renewals, cancellations, refunds and billing failures through **App Store
   Server Notifications / Play Real-Time Developer Notifications**. A subscription's state changes long
   after the purchase, so a one-shot check at purchase time is not enough.

Steps 4 and 5 are the hard parts, and they are why the follow-up should use **RevenueCat**: it owns
validation and both notification pipelines, and hands back a single "does this user have entitlement X"
answer plus a webhook. It is free under $2.5k/month revenue.

## The follow-up

The server half and the client half are both **built** (#155). What remains is Apple-side and testing:

- The `revenuecat-webhook` Edge Function maps store events onto `subscriptions` —
  [`docs/revenuecat-webhook-setup.md`](revenuecat-webhook-setup.md).
- `PurchaseService` (`lib/app/core/services/purchases/`) is the adapter over `purchases_flutter`, and
  `PremiumCubit` drives it. The paywall renders the store's own price, buys, and restores.

Still to do:

- Paid Applications agreement cleared (Banking status **Clear**) — until then the SDK returns an empty
  offering and the paywall shows "unavailable" rather than a price. That is expected, not a bug.
- `REVENUECAT_API_KEY` added as a GitHub secret, so release builds carry it. It is **optional** by design:
  a build without it still launches and works, it just has no purchasable offer, because nothing else in
  the app depends on purchases.
- Sandbox verification: buy, cancel, refund, restore — see #155's Phase 4.

Nothing in the domain, the data layer, the gate, or the two scan Edge Functions changed when this landed —
which was the point of granting premium by hand first.
