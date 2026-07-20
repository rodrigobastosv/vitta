# RevenueCat webhook — setup

The `revenuecat-webhook` Edge Function is the **only thing that ever writes `subscriptions`** once real purchases exist. RevenueCat validates receipts against Apple and Google and tells us the outcome; this function maps that onto the four statuses the app already understands. See [premium setup](premium-setup.md) for why the table is shaped the way it is, and why the scan functions read it rather than trusting the client.

**This function is called by RevenueCat, not by the app** — it is the first one in the project with no `SupabaseFunction` enum case, because nothing in Dart invokes it. That also means **`verify_jwt` must be disabled** for it: RevenueCat has no Supabase session, and the JWT check would reject every delivery before the handler ran. It authenticates on its own shared secret instead (step 3).

Like every other Edge Function here, **the source is deliberately not in this repo** — it lives only in the Supabase project and is edited in the dashboard. This runbook is where it is kept.

## The mapping, and the one case that is easy to get wrong

RevenueCat's `CANCELLATION` does **not** mean our `cancelled`. It fires both when a user turns off auto-renew *and* when they are refunded, distinguished only by `cancel_reason`:

- `cancel_reason: CUSTOMER_SUPPORT` is a **refund**. Access must be revoked **now**. Mapping it to our `cancelled` would be actively wrong, because `SubscriptionStatus.entitles` counts `cancelled` as entitling until `expires_at` — so a refunded user would keep the scans for the rest of a period they were paid back for.
- Every other reason (`UNSUBSCRIBE`, `PRICE_INCREASE`, `DEVELOPER_INITIATED`, `BILLING_ERROR`, `UNKNOWN`) means auto-renew is off but the paid period still runs. That is exactly our `cancelled`.

| RevenueCat event | `subscriptions.status` |
| --- | --- |
| `INITIAL_PURCHASE`, `RENEWAL`, `UNCANCELLATION`, `PRODUCT_CHANGE`, `SUBSCRIPTION_EXTENDED`, `NON_RENEWING_PURCHASE`, `REFUND_REVERSED`, `TEMPORARY_ENTITLEMENT_GRANT` | `active` |
| `CANCELLATION` with `cancel_reason: CUSTOMER_SUPPORT` | `expired` |
| `CANCELLATION`, any other reason | `cancelled` |
| `EXPIRATION`, `SUBSCRIPTION_PAUSED` | `expired` |
| `BILLING_ISSUE` | `in_grace_period` |
| everything else (`TEST`, `PAYWALL_*`, `TRANSFER`, `INVOICE_ISSUANCE`, …) | ignored, `200` |

**Ignored events must still answer `200`.** RevenueCat retries a non-200 five times and then stops sending altogether, so answering `400` to an event we simply do not model would eventually silence the whole integration. Ignoring is a success.

## Three traps the handler has to defend against

- **`app_user_id` may be `$RCAnonymousID:…`** — a purchase made before the app called `logIn(uid)`. It is not a Supabase user id, and inserting it violates the foreign key to `auth.users`, which would 500 and burn the retries. The handler requires a UUID and otherwise logs and returns 200.
- **Events arrive out of order and are retried.** A redelivered `RENEWAL` landing after a `CANCELLATION` would silently re-entitle someone. `subscriptions.last_event_at` is what stops that: an event not newer than the stored one is dropped. Retries of the *same* event are harmless anyway, since the write is an idempotent upsert of identical values.
- **`store` may be a value the check constraint rejects.** RevenueCat sends `APP_STORE`, `PLAY_STORE`, `RC_BILLING`, and others it may add later. `store` is nullable, so anything unrecognised is written as null rather than failing the insert.

## One-time setup

### 1. Update the table

Run `supabase/schema.sql` in the SQL editor (safe to re-run in full). It adds `last_event_at` and widens the `store` constraint to include `rc_billing`.

### 2. Create the function

**Edge Functions → Deploy a new function**, named exactly `revenuecat-webhook`. Paste the source below.

Then **disable JWT verification for it** — in the dashboard, the function's settings; or, if you ever deploy from the CLI, `verify_jwt = false` under `[functions.revenuecat-webhook]` in `supabase/config.toml`. Without this, every delivery is rejected before the handler runs.

### 3. Set the shared secret

Generate one (`openssl rand -hex 32`), then:

- In Supabase: **Project Settings → Edge Functions → Secrets**, as `REVENUECAT_WEBHOOK_SECRET`.
- In RevenueCat: **Integrations → Webhooks**, set the URL to `https://<your-project-ref>.supabase.co/functions/v1/revenuecat-webhook` and paste the same value into the **Authorization header** field.

The comparison is constant-time, so a wrong secret cannot be probed a character at a time.

> RevenueCat also offers HMAC-SHA256 signing (`X-RevenueCat-Webhook-Signature: t=…,v1=…` over `"<timestamp>.<raw body>"`), which additionally proves the body was not tampered with in transit and rejects replays. The shared header is what RevenueCat's own quickstart uses and is enough over TLS; switch to HMAC if that assumption ever stops holding.

### 4. Verify

RevenueCat's webhook page has a **Send test event** button, which sends `type: "TEST"`. A correct setup answers 200 and writes nothing (the dashboard shows the delivery as succeeded).

To exercise a real write, post a payload yourself with a real user's uuid:

```sh
curl -i -X POST 'https://<your-project-ref>.supabase.co/functions/v1/revenuecat-webhook' \
  -H 'Authorization: <REVENUECAT_WEBHOOK_SECRET>' \
  -H 'Content-Type: application/json' \
  -d '{
    "api_version": "1.0",
    "event": {
      "type": "INITIAL_PURCHASE",
      "app_user_id": "<a-real-auth-users-uuid>",
      "product_id": "vitta_premium_monthly",
      "store": "APP_STORE",
      "expiration_at_ms": 4102444800000,
      "event_timestamp_ms": 1893456000000
    }
  }'
```

Then check the row, and confirm the app unlocks the scans. Three follow-ups worth running once each, because they are the cases the design is actually about:

1. Re-send the **same** payload — the row should be unchanged (idempotent).
2. Send a `CANCELLATION` with `"cancel_reason": "CUSTOMER_SUPPORT"` and a *newer* `event_timestamp_ms` — status must become `expired`, and the scans must lock **even though `expires_at` is still in the future**. This is the refund case.
3. Re-send the original `INITIAL_PURCHASE` (older timestamp) — it must be **dropped**, leaving the status `expired`. This is the out-of-order guard.

## When a delivery fails

**`{"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}`, with `x-served-by: supabase-edge-runtime` and an `sb-error-code` header** — this is Supabase's gateway, not the function; the handler never ran. Two independent causes, and they look identical from RevenueCat's side:

- **`verify_jwt` is still enabled.** Fix this first (step 2). RevenueCat holds no Supabase session, so the gateway rejects every delivery before the handler is reached. With it on, the shared secret is rejected too — it is not a JWT — so setting the header alone will not help.
- **RevenueCat is not sending the header.** `NO_AUTH_HEADER` means it was absent rather than wrong, so the Authorization field in RevenueCat's webhook config is empty (step 3).

A `401 {"error":"unauthorized"}` **without** an `sb-error-code` header is the opposite situation and is good news: the gateway let the request through and our own `secretMatches` rejected it, so `verify_jwt` is off and only the secret is wrong.

## The function

```ts
// Receives RevenueCat subscription events and maps them onto the four statuses
// in `subscriptions`. This is the only writer of that table; the app can only
// read its own row (see supabase/schema.sql), and the scan functions read it to
// decide whether to run.
//
// Called by RevenueCat, not by the app, so it has no SupabaseFunction enum case
// and must be deployed with verify_jwt disabled - RevenueCat holds no Supabase
// session. It authenticates on REVENUECAT_WEBHOOK_SECRET instead.

import { createClient } from "jsr:@supabase/supabase-js@2";

const WEBHOOK_SECRET = Deno.env.get("REVENUECAT_WEBHOOK_SECRET")!;

// Anything not listed is ignored. RevenueCat adds event types without changing
// api_version, so an unknown type is expected traffic, not an error.
const ACTIVATING_EVENTS = [
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "SUBSCRIPTION_EXTENDED",
  "NON_RENEWING_PURCHASE",
  "REFUND_REVERSED",
  "TEMPORARY_ENTITLEMENT_GRANT",
];
const REVOKING_EVENTS = ["EXPIRATION", "SUBSCRIPTION_PAUSED"];

const STORES: Record<string, string> = {
  APP_STORE: "app_store",
  PLAY_STORE: "play_store",
  RC_BILLING: "rc_billing",
};

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

interface RevenueCatEvent {
  type?: string;
  app_user_id?: string;
  product_id?: string;
  store?: string;
  cancel_reason?: string;
  expiration_at_ms?: number;
  event_timestamp_ms?: number;
}

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

// Constant-time, so the secret cannot be probed one character at a time.
function secretMatches(provided: string | null): boolean {
  if (!provided || provided.length !== WEBHOOK_SECRET.length) {
    return false;
  }
  let difference = 0;
  for (let i = 0; i < provided.length; i++) {
    difference |= provided.charCodeAt(i) ^ WEBHOOK_SECRET.charCodeAt(i);
  }
  return difference === 0;
}

// CANCELLATION covers both "auto-renew turned off" and "refunded", told apart
// only by cancel_reason. A refund has to revoke access now: our `cancelled`
// entitles until expires_at, which for a refund is a period already paid back.
function statusFor(event: RevenueCatEvent): string | null {
  if (ACTIVATING_EVENTS.includes(event.type ?? "")) {
    return "active";
  }
  if (REVOKING_EVENTS.includes(event.type ?? "")) {
    return "expired";
  }
  if (event.type === "BILLING_ISSUE") {
    return "in_grace_period";
  }
  if (event.type === "CANCELLATION") {
    return event.cancel_reason === "CUSTOMER_SUPPORT" ? "expired" : "cancelled";
  }
  return null;
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }
  if (!secretMatches(request.headers.get("Authorization"))) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }

  let event: RevenueCatEvent;
  try {
    ({ event } = await request.json());
  } catch {
    return jsonResponse({ error: "Body must be JSON" }, 400);
  }
  if (!event) {
    return jsonResponse({ error: "event is required" }, 400);
  }

  // Every early return below is a 200. A non-200 is retried five times and then
  // RevenueCat stops delivering altogether, so refusing traffic we simply do not
  // model would eventually silence the integration. Ignoring is a success.
  const status = statusFor(event);
  if (!status) {
    return jsonResponse({ ignored: event.type ?? "unknown" }, 200);
  }

  // A purchase made before the app called logIn(uid) carries RevenueCat's own
  // anonymous id, which is not a Supabase user and would violate the foreign key.
  const userId = event.app_user_id ?? "";
  if (!UUID_PATTERN.test(userId)) {
    console.warn("ignoring event for non-Supabase app_user_id", userId);
    return jsonResponse({ ignored: "anonymous_app_user_id" }, 200);
  }

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const eventAt = new Date(event.event_timestamp_ms ?? Date.now()).toISOString();

  // Webhooks are retried and can arrive out of order: a redelivered RENEWAL
  // landing after a CANCELLATION would silently re-entitle someone.
  const { data: current, error: readError } = await admin
    .from("subscriptions")
    .select("last_event_at")
    .eq("user_id", userId)
    .maybeSingle();

  if (readError) {
    console.error("subscription read failed", readError);
    return jsonResponse({ error: "read failed" }, 500);
  }
  if (current?.last_event_at && new Date(current.last_event_at) >= new Date(eventAt)) {
    return jsonResponse({ ignored: "stale_event" }, 200);
  }

  const { error: writeError } = await admin.from("subscriptions").upsert({
    user_id: userId,
    product_id: event.product_id ?? "unknown",
    status,
    // Nullable, so a store RevenueCat adds later lands as null rather than
    // failing the check constraint and burning the retries.
    store: STORES[event.store ?? ""] ?? null,
    expires_at: event.expiration_at_ms
      ? new Date(event.expiration_at_ms).toISOString()
      : null,
    last_event_at: eventAt,
    updated_at: new Date().toISOString(),
  });

  // A 500 here is deliberate: this one RevenueCat SHOULD retry, because the
  // event was valid and we failed to record it.
  if (writeError) {
    console.error("subscription upsert failed", writeError);
    return jsonResponse({ error: "write failed" }, 500);
  }

  return jsonResponse({ status }, 200);
});
```

## Changing it

If the four statuses ever change, three places move together: `SubscriptionStatus` (`lib/app/domain/premium/entities/subscription_status.dart`), the `premiumRefusal` helper in both scan functions, and `statusFor` here. The check constraint on `subscriptions.status` is what will catch a mismatch, loudly, on the first delivery.
