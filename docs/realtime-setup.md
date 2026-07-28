# Realtime setup

One-time setup so the app is told about its own changes instead of re-reading a
whole screen every time you come back to it (issue #265). Until it is done the
app still works exactly as before — every read still happens, the pages just do
not get the "something changed" nudge.

## What it does

`RealtimeService` (`lib/app/core/services/supabase/realtime_service.dart`) opens a
`postgres_changes` subscription per watched table. `HomeCubit` and `DietCubit`
listen through `SyncRepository`/`WatchDataChangesUseCase` and re-read **only the
section that changed** when one fires. Because Home stays mounted underneath every
feature page, logging food on the Diet page updates Home while you are still on
Diet — so coming back costs nothing.

It reports *that* a table changed, never the row itself. A `postgres_changes`
payload is the raw row, and nothing this app renders is a raw row (a `food_logs`
insert carries no joined `foods`, so it has no calories in it). Re-reading is also
what makes an echo of this device's own write harmless: the re-read is
authoritative, so an optimistic total settles instead of double-counting.

## Steps

1. **Run `supabase/schema.sql`** in the Supabase SQL editor, as with every other
   schema change in this project. The block at the end of the file adds the eight
   per-user log tables to the `supabase_realtime` publication. It is idempotent —
   it checks `pg_publication_tables` first, so re-running is safe.

2. **Verify the publication.** In the SQL editor:

   ```sql
   select tablename from pg_publication_tables
   where pubname = 'supabase_realtime' and schemaname = 'public'
   order by tablename;
   ```

   You should see `body_weight_logs`, `food_logs`, `reminders`, `sleep_logs`,
   `water_logs`, `workout_exercises`, `workout_sets`, `workouts`.

3. **Check Realtime is enabled for the project** — Dashboard → Settings → API →
   Realtime. It is on by default; a project that has had it turned off will
   connect and then silently deliver nothing.

There is no client configuration and no new environment variable: the socket rides
on the same `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY` the rest of the app uses, and
on the anonymous session `bootstrap` already establishes.

## RLS

Nothing extra to do, and nothing to relax. Realtime evaluates the subscriber's JWT
against each table's own RLS policy before delivering a row, so every user only
ever hears about their own — the same `auth.uid()` policies that already scope the
reads. **Do not add a permissive policy to make realtime "work"**: if a table goes
quiet, the cause is the publication (step 1) or the socket, not the policy.

`workout_exercises` and `workout_sets` carry no `user_id` of their own — their
policies walk up to the owning workout. If Realtime cannot evaluate that subquery
in your project, those two simply never fire, which degrades to the ordinary reads
rather than leaking anything.

## What this deliberately does not replace

Realtime has **no replay**. A socket suspended with the app misses every event
fired while it was away and Supabase will not resend them, so it can never be the
source of truth. Two things follow, and both are already in the code:

- `RealtimeService` re-emits every watched table on `AppLifecycleState.resumed`, so
  a subscriber re-reads whatever it slept through.
- The pop-refreshes on Home and Diet were **kept**, not deleted. They are now quiet
  (`LoadTrigger.quiet`, no overlay) and usually a no-op because realtime already
  settled the data, but they are what makes the app correct on a device where step
  1 was never run, where the socket dropped, or where an event was missed.

## Cost

One websocket per running app, and one extra section read per change. Supabase's
free tier allows 200 concurrent connections and 2M messages/month, which a
single-user-per-device app is nowhere near.
