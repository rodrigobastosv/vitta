# Play Store setup (Android production + purchases)

One-time setup that takes Android from "beta delivery only" to "installable from a
Play track, and able to purchase" (issue #223). None of this lives in the repo, and
until it is done Android can be handed to testers but **cannot sell anything** — the
two facts are the same fact (see the Android section of
[`premium-setup.md`](premium-setup.md)).

The one code change is already in the repo:
[`android/app/build.gradle.kts`](../android/app/build.gradle.kts) signs the `release`
build with the **upload key** when `android/key.properties` is present, and falls back
to the committed debug keystore otherwise. So:

- **Firebase lane** (`firebase-android.yml`) has no `key.properties` → still debug-signed
  → beta drops keep working, and stay **unable to purchase** (that is fine, it is stated).
- **Play build** (local, or the future Play CI lane) writes `key.properties` → signed with
  the upload key → the only signature Play Billing serves products to.

**These cannot be the same artifact.** A debug-signed Firebase APK and an upload-signed
Play bundle are two different builds for two different audiences.

App identity, for reference: application id `com.rodrigobastosv.vitta` (same as iOS).

---

## Prerequisites

- Part 1 (Play Console app record under `com.rodrigobastosv.vitta`) — **done**.
- Store listing, content rating, Data Safety, target audience, privacy policy filled in
  on the Play Console. Play refuses to promote a release without them. **Data Safety must
  state what Vitta actually collects** — progress photos, body weight, sleep (see the
  private-bucket note in `supabase/schema.sql`). It does not have to be complete to upload
  to *internal testing*, but it does before any wider track.

---

## 1. Generate the upload key

Run once, locally. Keep the answers — the passwords cannot be recovered, and losing this
key means losing the ability to update the app (Play App Signing mitigates this, but do
not rely on it).

```sh
keytool -genkey -v -keystore ~/vitta-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias vitta-upload
```

Store it **outside the repo** (home directory above). The repo's `.gitignore` already
ignores `**/*.jks` and `key.properties`, but keeping the keystore out of the tree entirely
removes the risk altogether.

## 2. Point the build at it — `android/key.properties`

Create `android/key.properties` (gitignored — never commit it):

```properties
storePassword=<the store password you just chose>
keyPassword=<the key password you just chose>
keyAlias=vitta-upload
storeFile=/Users/rodrigobvasc/vitta-upload-keystore.jks
```

`storeFile` is an absolute path. `build.gradle.kts` reads this file via
`rootProject.file("key.properties")` (i.e. `android/key.properties`) and wires the
`upload` signing config from it.

## 3. Build the signed App Bundle

Play requires an **`.aab`** (App Bundle), not an APK.

```sh
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`. Confirm it is upload-signed,
not debug-signed:

```sh
jarsigner -verify -verbose -certs \
  build/app/outputs/bundle/release/app-release.aab | grep -i "CN="
```

The alias should read your `vitta-upload` certificate, not `androiddebugkey`.

> A build needs `.env` present (it is a bundled asset). Locally you already have it; the
> future CI lane writes it from secrets exactly as the Firebase lane does.

## 4. Upload to internal testing + enrol in Play App Signing

The **first** bundle for a new app is uploaded through the Console UI by hand — that upload
is where Play App Signing enrolment happens, and the Play Developer API will not accept
releases on a track until the app has one release.

1. Play Console → your app → **Testing → Internal testing** → **Create new release**.
2. When prompted about **Play App Signing**, accept (let Google manage the app signing key;
   your `vitta-upload` key stays the *upload* key). This is the recommended path and what
   the RevenueCat/Play integration expects.
3. Upload `app-release.aab`. Fill the release notes, **Save → Review → Rollout to Internal
   testing**.
4. **Testers** tab of the internal track → add tester email addresses (or a Google Group),
   and copy the **opt-in URL**. Each tester opens it once and accepts, then installs Vitta
   **from the Play Store** (not Firebase) on that account.

## 5. License testing (buy without being charged)

Play Console (account level, not the app) → **Settings → License testing** → add the same
tester Google accounts. On those accounts, subscription purchases on the internal track
complete against a test card and are **not** charged, and renew on an accelerated clock.

## 6. Finish the RevenueCat Android side

Blocked until parts 1–4 exist (the service account needs the Play app to exist). Full steps
are in [`premium-setup.md`](premium-setup.md#android-issue-218); in short:

1. **Play Console → Monetize → Subscriptions**: create `vitta_premium_monthly` with a base
   plan, and **activate both** the subscription and the base plan. A draft is not fetchable.
2. **Google Cloud → IAM** service account with Play access (granted in Play Console →
   **Users and permissions**), download its JSON key.
3. **RevenueCat → Apps → + Android**: package `com.rodrigobastosv.vitta`, upload that Play
   service-account JSON.
4. **RevenueCat → Products**: add the Play product as **`subscriptionId:basePlanId`**
   (e.g. `vitta_premium_monthly:monthly`) — **not** the bare subscription id, which is the
   usual reason a product looks registered but never resolves.
5. **RevenueCat → Offerings**: attach it to a package in the **current** offering (the same
   one iOS uses). `PurchaseService.fetchOffers` reads `offerings.current`.
6. Confirm `REVENUECAT_ANDROID_API_KEY` is set as a GitHub secret (it already is, since
   #218) so release builds carry the Android SDK key.

## 7. Verify end to end

On a device signed into a **license-testing account**, installed **from the internal
track**:

- The paywall shows the **real price** (not "unavailable").
- **Buy** → the two AI scans unlock; `revenuecat-webhook` writes the `subscriptions` row
  with `store = 'play_store'` (check the table in Supabase).
- **Cancel** (turn off auto-renew) → still entitled until period end.
- **Refund** (Play Console → Order management) → entitlement drops (`status = 'expired'`).
- **Restore** on a reinstall → entitlement returns.

This is the same Phase 4 list #155 defines for iOS. If the paywall still says
"unavailable", read the error-text table in
[`premium-setup.md`](premium-setup.md#read-the-error-text--it-names-which-step-you-are-on)
— the SDK message names which step you are on.

---

## Later: automating the Play upload in CI

Deferred until the app is live on the internal track (part 4) and the Play Developer API
service account is set up. When ready, add a `play-android.yml` lane, parallel to the
Firebase one, that:

1. Writes `android/key.properties` and decodes the keystore from secrets:
   - `ANDROID_UPLOAD_KEYSTORE_BASE64` — `base64 -i ~/vitta-upload-keystore.jks | pbcopy`
   - `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`
2. Runs `flutter build appbundle --release` with `.env` written from secrets (reuse the
   Firebase lane's `Write .env from secrets` step verbatim).
3. Uploads to the internal track with `r0adkll/upload-google-play`, using the Play
   Developer API service-account JSON (`PLAY_SERVICE_ACCOUNT_JSON` secret — this is the
   **Play** service account, distinct from the Firebase App Distribution one).

The Firebase lane stays as-is for fast beta drops; the Play lane is the billable artifact.
