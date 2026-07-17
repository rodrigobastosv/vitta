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

The app code is cross-platform — `HealthService` reads from HealthKit on iOS the same way it
reads Health Connect on Android. The Dart side and `Info.plist` usage strings
(`NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription`) are already in the repo. To
activate it you must enable the **HealthKit capability** in Xcode (Runner target → Signing &
Capabilities → + Capability → HealthKit), which writes `Runner.entitlements` and wires
`CODE_SIGN_ENTITLEMENTS`, and add the HealthKit capability to the `match` provisioning profile
(see [`docs/testflight-setup.md`](testflight-setup.md)).

Note: a Samsung/Wear OS watch cannot pair with an iPhone, so its data never reaches Apple Health —
the HealthKit path only surfaces data from Apple Watch (or other apps that write sleep to Apple
Health). Until the capability is enabled, iOS calls fail gracefully and the app shows a
"couldn't connect" message.
