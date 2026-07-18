# Health sleep import setup

Vitta can import sleep from the device's health platform. The user's watch syncs sleep to the
platform's health hub (**Health Connect** on Android, **Apple Health** on iOS) and Vitta reads it
from there — Vitta never talks to the watch directly. The first supported path is **Android /
Health Connect** (a Samsung/Wear OS watch flows Galaxy Watch → Samsung Health → Health Connect).

## 1. Database (run once in the Supabase SQL editor)

The columns are already in [`supabase/schema.sql`](../supabase/schema.sql); apply them to your
project:

```sql
alter table sleep_logs add column if not exists source text not null default 'manual'
  check (source in ('manual', 'health'));
alter table sleep_logs add column if not exists external_id text;

create unique index if not exists sleep_logs_user_id_external_id_key
  on sleep_logs (user_id, external_id)
  where external_id is not null;
```

`source` marks how a night was captured; `external_id` holds the health record's id so a re-sync
upserts the same night (on `user_id, external_id`) instead of duplicating it.

## 2. Android (Health Connect)

Already wired in the repo:

- `health` dependency in `pubspec.yaml`.
- `minSdk = 26` in `android/app/build.gradle.kts` (Health Connect requires API 26+).
- `android.permission.health.READ_SLEEP`, the Health Connect `<queries>` package, and the
  permissions-rationale intent-filter in `android/app/src/main/AndroidManifest.xml`.

On the user's device:

1. In **Samsung Health → Settings → Health Connect**, allow it to write **Sleep** (one-time).
   Health Connect is built into Android 14+; on Android 13 and below install it from the Play Store.
2. In Vitta, open **Sleep → Sync** and grant the Health Connect sleep permission when prompted.

Testing without a watch: on an emulator/device, use the debug-only **"insert sample sleep"** action
on the Sleep page (visible only in debug builds) to seed a session, then Sync.

## 3. Release-only (deferred — not needed for `flutter run`/dev builds)

Publishing to the Play Store with Health Connect requires:

- A published **privacy policy URL** describing the health-data usage.
- Google Play's **Health Connect declaration form** in the Play Console.

## 4. iOS (Apple Health)

The app code is cross-platform — `HealthService` reads from HealthKit on iOS the same way it reads
Health Connect on Android. Already wired in the repo:

- `ios/Runner/Runner.entitlements` with `com.apple.developer.healthkit`, referenced from all three
  Runner build configs via `CODE_SIGN_ENTITLEMENTS`.
- `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription` in `ios/Runner/Info.plist`.

**To ship an iOS/TestFlight build you must enable HealthKit on the signing side** (one-time,
owner-only — the entitlement in the app must match the provisioning profile):

1. Enable **HealthKit** on the App ID `com.rodrigobastosv.vitta` in the Apple Developer portal
   (Certificates, IDs & Profiles → Identifiers → the app → HealthKit).
2. Regenerate the App Store provisioning profile so it includes HealthKit, and push it to the
   `match` repo: `bundle exec fastlane match appstore --force` (needs write access — CI runs
   `match` read-only). See [`docs/testflight-setup.md`](testflight-setup.md).
3. Local `flutter run` uses automatic signing, so Xcode adds the capability to your dev profile on
   its own once the entitlement is present.

Internal TestFlight testing (your own team) does not need Beta App Review; external testers do.

Note: a Samsung/Wear OS watch cannot pair with an iPhone, so its data never reaches Apple Health —
the HealthKit path surfaces data from an Apple Watch (or other apps that write sleep to Apple
Health).
