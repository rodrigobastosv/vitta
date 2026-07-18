# Firebase App Distribution setup (Android)

One-time setup for the `v*` tag → Firebase App Distribution pipeline
(`.github/workflows/firebase-android.yml`). None of this lives in the repo, and
until every step is done the workflow fails.

iOS is **not** distributed through Firebase — it stays on TestFlight
(`docs/testflight-setup.md`). Firebase for iOS would require ad-hoc signing and
registering every tester's device UDID; TestFlight needs neither, so each platform
uses the tool that's simplest for it. This runbook is Android only.

Once it's green, the same release ritual that ships iOS also ships Android:

```sh
git tag v1.2.3 && git push origin v1.2.3
```

App identity, for reference: application id `com.rodrigobastosv.vitta`.

---

## 1. Create the Firebase project and register the Android app

1. <https://console.firebase.google.com> → **Add project** (name `Vitta`). Google
   Analytics is optional and not used here.
2. In the project, **Add app** → **Android**. Package name **exactly**
   `com.rodrigobastosv.vitta`. You can skip downloading `google-services.json` and
   skip the SDK steps — App Distribution doesn't need the Firebase SDK linked into
   the app, only the app record.
3. Left nav → **Run** → **App Distribution** → **Get started** for the Android app.
4. **Testers & Groups** tab → create a group with the alias **`testers`** (the
   workflow distributes to this exact alias) and add tester emails. Each tester
   accepts the invite email once and installs the Firebase App Tester app.

### The Firebase Android App ID → `FIREBASE_ANDROID_APP_ID`

Project settings (gear) → **General** → your Android app → **App ID**. It looks
like `1:1234567890:android:abc123def456`. This is *not* the package name.

## 2. Service account with upload rights → `FIREBASE_SERVICE_ACCOUNT`

The CLI authenticates as a service account, not a person.

1. <https://console.cloud.google.com/iam-admin/serviceaccounts> (same Google project
   as Firebase) → **Create service account**. Name `github-firebase-distribution`.
2. Grant it the **Firebase App Distribution Admin** role (search "App Distribution
   Admin"). That's the only role it needs.
3. Open the created account → **Keys** → **Add key** → **Create new key** → **JSON**.
   A `.json` file downloads.
4. Paste the **entire JSON file contents** into the `FIREBASE_SERVICE_ACCOUNT`
   secret (see step 4). Not base64 — the raw JSON.

## 3. Signing — nothing to do

There's no keystore to generate and no signing secrets. Android builds are signed
with a **committed** debug keystore (`android/app/debug.keystore`, well-known public
`android` password) that `android/app/build.gradle.kts` points every build at. That's
what gives each build the same signature so Firebase can update a tester's install in
place — a CI-generated debug keystore would change signature every run and force a
reinstall each drop. It is not a Play Store upload key: if a Play pipeline is ever
added, generate a real release key then.

## 4. GitHub secrets

<https://github.com/rodrigobastosv/vitta/settings/secrets/actions> → **New
repository secret** for each. The three Supabase/Sentry ones are already set for the
TestFlight pipeline and are reused as-is; only two new ones are needed.

Reused (already present):

- `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SENTRY_DSN`

New:

- `FIREBASE_ANDROID_APP_ID` — from step 1
- `FIREBASE_SERVICE_ACCOUNT` — the raw JSON from step 2

Every one of these is checked for emptiness at the top of its workflow step, so a
missing secret fails fast with a named error rather than shipping a broken build.

---

## Releasing

```sh
git tag v1.2.3 && git push origin v1.2.3
```

Both pipelines fire on the tag: TestFlight builds and uploads the iOS build, Firebase
builds and distributes the Android APK. The version comes from the tag (`1.2.3`); the
Android `versionCode` is the workflow run number, which only ever increases.
