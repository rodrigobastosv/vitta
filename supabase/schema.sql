-- Vitta schema. Source of truth for every feature's tables.
-- Run in the Supabase project's SQL editor (Project > SQL Editor > New query).
-- Safe to re-run in full: tables/indexes use if not exists, and policies are
-- dropped and recreated (Postgres has no "create policy if not exists").

-- `foods` is a catalog shared across every user, not a per-user table: `user_id`
-- only records who first added a row (for the update/delete policies below),
-- it doesn't scope visibility. `barcode` is deduplicated so the same product
-- looked up by different users reuses one row (see foods_barcode_unique_idx).
-- `user_id` is null for rows bulk-imported from an external database (see
-- tool/import_food_catalog.dart) rather than added by a specific user - those
-- writes go through the service_role key, which bypasses RLS entirely, so the
-- insert/update/delete policies below never need to account for a null user_id
-- themselves (they simply never match one, which is the point: nobody using
-- the app can edit or delete an imported row through it).
create table if not exists foods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  name text not null,
  brand text,
  barcode text,
  source text not null check (source in ('custom', 'open_food_facts')),
  calories_per_100g numeric not null check (calories_per_100g >= 0),
  protein_per_100g numeric not null check (protein_per_100g >= 0),
  carbs_per_100g numeric not null check (carbs_per_100g >= 0),
  fat_per_100g numeric not null check (fat_per_100g >= 0),
  fiber_per_100g numeric not null default 0 check (fiber_per_100g >= 0),
  -- Vitamins and minerals per 100g, keyed by Nutrient.wireKey (see
  -- lib/app/domain/diet/entities/nutrient.dart). A keyed JSONB blob rather than
  -- one column per nutrient: there are ~dozens, coverage is sparse (most Open
  -- Food Facts rows only carry macros), and new nutrients shouldn't need a
  -- migration - each is just another enum case on the app side.
  micronutrients jsonb not null default '{}',
  image_url text,
  -- How many times this food has been logged across every user, maintained by
  -- the food_logs trigger below so catalog search can rank popular products
  -- first (see issue #56). Denormalized onto foods because food_logs' RLS scopes
  -- each user to their own rows, so this count can't be aggregated client-side.
  times_logged integer not null default 0 check (times_logged >= 0),
  created_at timestamptz not null default now()
);

-- Added after the initial release; existing tables get backfilled with 0/null.
alter table foods add column if not exists fiber_per_100g numeric not null default 0 check (fiber_per_100g >= 0);
alter table foods add column if not exists micronutrients jsonb not null default '{}';
alter table foods add column if not exists image_url text;
alter table foods add column if not exists times_logged integer not null default 0 check (times_logged >= 0);
alter table foods alter column user_id drop not null;

create index if not exists foods_user_id_idx on foods (user_id);

-- A plain (non-partial) unique index: Postgres already treats every NULL as
-- distinct from every other NULL, so custom foods (no barcode) are naturally
-- unrestricted without needing a `where barcode is not null` predicate - and
-- a partial index can't be used as a PostgREST on_conflict target anyway
-- (see tool/import_food_catalog.dart's upsert), so this also has to be the
-- plain form for that to work. Drop+recreate covers projects that already
-- created the old partial version.
drop index if exists foods_barcode_unique_idx;
create unique index if not exists foods_barcode_unique_idx on foods (barcode);

create table if not exists food_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  food_id uuid not null references foods (id) on delete cascade,
  logged_date date not null,
  meal_type text not null check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack')),
  quantity_grams numeric not null check (quantity_grams > 0),
  created_at timestamptz not null default now()
);

create index if not exists food_logs_user_id_logged_date_idx on food_logs (user_id, logged_date);

-- Keeps foods.times_logged (see the column comment) in sync with food_logs.
-- security definer so the counter can be bumped on a food row the logging user
-- doesn't own (imported rows have a null user_id) - foods' own update policy
-- would otherwise block it. It never touches food_logs itself, so there's no
-- risk of recursion. greatest(..., 0) keeps the counter from going negative if
-- a delete ever runs without a matching prior insert.
create or replace function bump_food_times_logged()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    update foods set times_logged = times_logged + 1 where id = new.food_id;
  elsif tg_op = 'DELETE' then
    update foods set times_logged = greatest(times_logged - 1, 0) where id = old.food_id;
  end if;
  return null;
end;
$$;

drop trigger if exists food_logs_bump_times_logged on food_logs;
create trigger food_logs_bump_times_logged
  after insert or delete on food_logs
  for each row execute function bump_food_times_logged();

-- Reconcile the counter from food_logs (the source of truth). Idempotent:
-- re-running the whole schema recomputes it from scratch rather than
-- double-counting - the reset zeroes every row first so a food that has since
-- lost all its logs is corrected back to 0, then the grouped count re-seeds the
-- rest.
update foods set times_logged = 0 where times_logged <> 0;
update foods f
set times_logged = sub.cnt
from (select food_id, count(*) as cnt from food_logs group by food_id) sub
where f.id = sub.food_id;

create table if not exists water_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  logged_date date not null,
  amount_ml numeric not null check (amount_ml > 0),
  created_at timestamptz not null default now()
);

create index if not exists water_logs_user_id_logged_date_idx on water_logs (user_id, logged_date);

create table if not exists sleep_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  logged_date date not null,
  bed_time timestamptz not null,
  wake_time timestamptz not null,
  quality_rating smallint check (quality_rating between 1 and 5),
  created_at timestamptz not null default now(),
  constraint sleep_logs_wake_after_bed check (wake_time > bed_time)
);

create index if not exists sleep_logs_user_id_logged_date_idx on sleep_logs (user_id, logged_date);

alter table foods enable row level security;
alter table food_logs enable row level security;
alter table water_logs enable row level security;
alter table sleep_logs enable row level security;

-- foods is a shared catalog (see comment on the table above): anyone
-- authenticated can read every row, but only the row's own author can
-- change or remove it.
drop policy if exists "Users manage their own foods" on foods;

drop policy if exists "Anyone can read foods" on foods;
create policy "Anyone can read foods" on foods
  for select
  using (true);

drop policy if exists "Users insert their own foods" on foods;
create policy "Users insert their own foods" on foods
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users update their own foods" on foods;
create policy "Users update their own foods" on foods
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users delete their own foods" on foods;
create policy "Users delete their own foods" on foods
  for delete
  using (auth.uid() = user_id);

drop policy if exists "Users manage their own food logs" on food_logs;
create policy "Users manage their own food logs" on food_logs
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their own water logs" on water_logs;
create policy "Users manage their own water logs" on water_logs
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their own sleep logs" on sleep_logs;
create policy "Users manage their own sleep logs" on sleep_logs
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Storage bucket for food photos attached via CustomFoodSheet. Public read
-- (images are shown in the shared foods catalog to every user), write
-- restricted to authenticated users (anonymous sessions count as
-- authenticated here, same as every other auth.uid() check above).
insert into storage.buckets (id, name, public)
values ('food-images', 'food-images', true)
on conflict (id) do nothing;

drop policy if exists "Anyone can view food images" on storage.objects;
create policy "Anyone can view food images" on storage.objects
  for select
  using (bucket_id = 'food-images');

drop policy if exists "Authenticated users can upload food images" on storage.objects;
create policy "Authenticated users can upload food images" on storage.objects
  for insert
  with check (bucket_id = 'food-images' and auth.uid() is not null);
