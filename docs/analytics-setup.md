# Google Analytics setup

One-time setup for the analytics integration (issue #174). Until it's done the
app still builds, launches and works — it simply reports nothing, exactly as a
build without a RevenueCat key simply has nothing to sell. **Analytics must never
be the reason the app fails to launch**, so every step here is optional to run
the app and mandatory to see a single number in the dashboard.

"Google Analytics" on a Flutter app means **Google Analytics for Firebase** (GA4):
the SDK is `firebase_analytics`, the data lands in a GA4 property, and the two are
linked by the Firebase project. There is no `gtag.js`-style option for a native
app.

App identity, for reference: `com.rodrigobastosv.vitta` on both stores.

---

## 1. Enable Google Analytics on the Firebase project

The project already exists — it's the one Android beta builds are distributed
through (`docs/firebase-distribution-setup.md`), and that runbook said Analytics
was optional and unused. It isn't anymore.

1. <https://console.firebase.google.com> → the **Vitta** project → gear →
   **Project settings** → **Integrations** → **Google Analytics** → **Enable**.
   Pick (or create) a GA4 account; Firebase creates the linked GA4 property.
2. **Data collection and data retention** → set **event data retention** to
   **14 months** (the default is 2, which quietly throws away everything a
   year-over-year question needs).

## 2. Register both apps

Android is already registered for App Distribution. iOS is not.

1. Project settings → **General** → **Your apps** → **Add app** → **iOS**, bundle
   id **exactly** `com.rodrigobastosv.vitta`.
2. For each app, download the config file — `google-services.json` (Android) /
   `GoogleService-Info.plist` (iOS). **Neither is committed.** You only need them
   open in a text editor to read the four values below out of; the app builds its
   `FirebaseOptions` from `.env` instead (see `AnalyticsService`), which keeps the
   config in the same place every other credential-shaped thing in this project
   lives and out of two platform folders.

## 3. The six `.env` values

| `.env` key | Android (`google-services.json`) | iOS (`GoogleService-Info.plist`) |
|---|---|---|
| `FIREBASE_PROJECT_ID` | `project_info.project_id` | `PROJECT_ID` |
| `FIREBASE_MESSAGING_SENDER_ID` | `project_info.project_number` | `GCM_SENDER_ID` |
| `FIREBASE_ANDROID_API_KEY` | `client[].api_key[0].current_key` | — |
| `FIREBASE_ANDROID_APP_ID` | `client[].client_info.mobilesdk_app_id` | — |
| `FIREBASE_IOS_API_KEY` | — | `API_KEY` |
| `FIREBASE_IOS_APP_ID` | — | `GOOGLE_APP_ID` |

The project id and sender id are **shared** — one project holds an app per store.
The API key and app id are **per store and not interchangeable**: handing an
Android build the iOS app id attributes its events to the wrong app, the same trap
the RevenueCat key documents (issue #218). `FIREBASE_ANDROID_APP_ID` is the value
the App Distribution workflow already uses — it is one app, distributed and
measured.

These are **not secrets.** They ship inside the binary and are readable by anyone
who unzips the app; access is governed by Firebase security rules, not by hiding
them. They live in `.env` for consistency and because `.env` is gitignored, not
because leaking one is a breach.

Fill them into your local `.env` (copy from `.env.example`), then add the six as
GitHub secrets of the same names — the release workflows write them into the
bundled `.env` alongside the Supabase, Sentry and RevenueCat values.

Leaving any one empty disables analytics entirely for that build (`AnalyticsService`
requires all four of the platform's values before it initialises Firebase at all),
which is a legitimate state — not a half-configured one that reports garbage.

## 4. Verify

`DebugView` is the only honest way to check: ordinary GA4 reporting is batched and
delayed by hours, so "I see nothing" a minute after launching means nothing.

```sh
# Android
adb shell setprop debug.firebase.analytics.app com.rodrigobastosv.vitta
# iOS: add -FIRDebugEnabled to the scheme's launch arguments in Xcode
```

Then Firebase console → **Analytics** → **DebugView**, launch the app, and walk
around it. You should see `screen_view` on every push and every screen you return
to, plus the app's own events (`food_logged`, `water_logged`, `workout_set_logged`,
…) as you use it.

Turn it back off with `adb shell setprop debug.firebase.analytics.app .none.`.

---

## What gets reported, and what doesn't

Everything flows through the existing `Log` facade — `AnalyticsLogDestination` is
one more `LogDestination` next to the console and Sentry sinks, so the ~50 call
sites that already name a `snake_case` event were instrumented for analytics
before analytics existed. **Adding an event means calling `Log.action(...)` on a
cubit's success path, exactly as before; nothing imports the analytics service.**

- **Events** — every `Log.action('<snake_case>', data: {...})`.
- **Screen views** — every route push, replace and `reveal` (a screen returned
  to). A `pop` is not a screen view: it names the screen being *left*.
- **User id** — the Supabase `auth.uid()`, set at bootstrap and again whenever
  `AuthCubit` signs in, signs out or deletes the account. Signing out clears it,
  so the fresh anonymous session does not inherit the previous person's funnel.

Not reported, deliberately:

- **Identity and free text.** Never put an email, a display name, a reminder's
  note or anything else the user wrote for themselves into a `Log.action`
  payload. Existing payloads carry enum names, counts, amounts and — in
  `food_logged` — the food's catalog name, which is a product, not a person.
  The one soft edge: a *custom* food's name was typed by the user, so it reaches
  GA4 as an event parameter. That is accepted (it is a food, and it already joins
  the shared catalog every other user searches), but it is the line, not a
  precedent to extend.
- **`Result`/`VTError` failures.** They are already-handled paths shown as a
  toast, and the same reasoning that keeps them out of Sentry keeps them out of
  analytics.

GA4's limits are silent — a too-long name, a `firebase_`-prefixed event, a 26th
parameter or a `bool` value is dropped without an error, and the only symptom is a
figure that never appears. `AnalyticsParameters` enforces all of them in one place
so no call site has to know them.
