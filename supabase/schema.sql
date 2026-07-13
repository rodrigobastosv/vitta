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
  created_at timestamptz not null default now()
);

-- Added after the initial release; existing tables get backfilled with 0/null.
alter table foods add column if not exists fiber_per_100g numeric not null default 0 check (fiber_per_100g >= 0);
alter table foods add column if not exists micronutrients jsonb not null default '{}';
alter table foods add column if not exists image_url text;
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
