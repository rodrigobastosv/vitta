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
  -- What one whole item of this food weighs, so it can be logged as "2 eggs"
  -- rather than "100 g" (see issue #114). A property of the food, not of any
  -- quantity, which is why it lives here and not on food_logs. Null means the
  -- food is not countable - rice and milk are measured, not counted - and the
  -- log sheet then offers no unit mode at all.
  grams_per_unit numeric check (grams_per_unit > 0),
  -- When tool/populate_food_unit_weights.dart last asked the converter API
  -- about this row. Null means never asked; non-null alongside a null
  -- grams_per_unit means "asked, and it is not countable". Without this the
  -- null above would conflate "unchecked" with "not countable" and every
  -- re-run would re-ask an LLM about every bulk food forever.
  grams_per_unit_checked_at timestamptz,
  created_at timestamptz not null default now()
);

-- Added after the initial release; existing tables get backfilled with 0/null.
alter table foods add column if not exists fiber_per_100g numeric not null default 0 check (fiber_per_100g >= 0);
alter table foods add column if not exists micronutrients jsonb not null default '{}';
alter table foods add column if not exists image_url text;
alter table foods add column if not exists times_logged integer not null default 0 check (times_logged >= 0);
alter table foods add column if not exists grams_per_unit numeric check (grams_per_unit > 0);
alter table foods add column if not exists grams_per_unit_checked_at timestamptz;
alter table foods alter column user_id drop not null;

-- 'recipe' was added for issue #63: a recipe is stored as an ordinary foods row
-- whose macros are the per-100g roll-up of its ingredients, so logging a recipe
-- is the plain logFood path and every day/calendar/history view keeps working
-- untouched. The recipes table below only holds the ingredient list behind it.
alter table foods drop constraint if exists foods_source_check;
alter table foods add constraint foods_source_check check (source in ('custom', 'open_food_facts', 'recipe'));

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
  -- How many whole items were logged, when the user entered a count rather than
  -- a weight (see foods.grams_per_unit). Null means logged by weight.
  -- quantity_grams above stays not null and is always the source of truth for
  -- every calorie and macro: this column only records how the number was typed,
  -- so that the day view can say "2 un" back. It is deliberately never used to
  -- recompute grams - a later re-run of the converter that revises a food's
  -- grams_per_unit must not retroactively move yesterday's calories.
  quantity_units numeric check (quantity_units > 0),
  created_at timestamptz not null default now()
);

alter table food_logs add column if not exists quantity_units numeric check (quantity_units > 0);

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

-- A recipe is a set of foods eaten together. It owns no macros of its own: the
-- foods row it points at (source = 'recipe') carries the rolled-up per-100g
-- values, and this table plus recipe_ingredients only records what it was built
-- from, so it can be listed and rebuilt. Deleting a recipe deliberately leaves
-- its foods row behind - past food_logs still reference it and must keep
-- resolving, exactly like any other food you logged once and stopped using.
create table if not exists recipes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  food_id uuid not null references foods (id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists recipes_user_id_idx on recipes (user_id);

create table if not exists recipe_ingredients (
  id uuid primary key default gen_random_uuid(),
  recipe_id uuid not null references recipes (id) on delete cascade,
  food_id uuid not null references foods (id) on delete cascade,
  quantity_grams numeric not null check (quantity_grams > 0),
  created_at timestamptz not null default now()
);

create index if not exists recipe_ingredients_recipe_id_idx on recipe_ingredients (recipe_id);

-- Favourites are a plain join table rather than a flag on foods: foods is a
-- shared catalog, so "is this a favourite" is per-user and cannot live on the
-- row everyone reads. Recipes need nothing extra here - a recipe *is* a foods
-- row (source: 'recipe'), so favouriting one is the same insert as any other
-- food. Deleting the food (or the user) takes its favourites with it.
create table if not exists food_favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  food_id uuid not null references foods (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, food_id)
);

create index if not exists food_favorites_user_id_idx on food_favorites (user_id);

-- `exercises` is a catalog shared across every user, exactly like `foods`:
-- `user_id` only records who added a row, it doesn't scope visibility. The bulk
-- of it is imported from the free-exercise-db public-domain dataset (see
-- tool/import_exercise_catalog.dart) through the service_role key, which
-- bypasses RLS - those rows have a null user_id, so the insert/update/delete
-- policies below never match one and nobody can edit an imported exercise
-- through the app. `slug` is the dataset's own id, deduplicated so re-running
-- the import updates rows instead of duplicating them.
--
-- `names` and `instructions` are JSONB keyed by locale ({"en": ..., "pt": ...})
-- rather than a name/name_pt column pair: the dataset ships English only and
-- the import translates it, so a locale added later is an import re-run and an
-- ARB file, never a migration. Same reasoning as foods.micronutrients.
-- `instructions` holds an array of steps per locale.
create table if not exists exercises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  slug text,
  names jsonb not null default '{}',
  instructions jsonb not null default '{}',
  category text not null check (category in ('strength', 'cardio', 'stretching', 'plyometrics', 'powerlifting', 'olympic_weightlifting', 'strongman')),
  equipment text check (equipment in ('barbell', 'dumbbell', 'kettlebells', 'cable', 'machine', 'bands', 'body_only', 'exercise_ball', 'medicine_ball', 'foam_roll', 'e_z_curl_bar', 'other')),
  force text check (force in ('push', 'pull', 'static')),
  level text not null check (level in ('beginner', 'intermediate', 'expert')),
  mechanic text check (mechanic in ('compound', 'isolation')),
  -- Muscle names as text arrays rather than a join table: they're a closed set
  -- from a fixed enum on the app side (see lib/app/domain/workout/entities/
  -- muscle_group.dart), never independently queried, and a GIN-indexed array
  -- filters "exercises for chest" in one predicate with no join.
  primary_muscles text[] not null default '{}',
  secondary_muscles text[] not null default '{}',
  -- Public URLs into the exercise-images bucket, in display order.
  image_urls text[] not null default '{}',
  -- How many times this exercise has been logged across every user, maintained
  -- by the workout_exercises trigger below so catalog search ranks the popular
  -- ones first. Denormalized onto exercises for the same reason foods
  -- .times_logged is: workout RLS scopes each user to their own rows, so this
  -- can't be aggregated client-side.
  times_logged integer not null default 0 check (times_logged >= 0),
  created_at timestamptz not null default now()
);

-- What catalog search actually matches on: every locale's name folded into one
-- lowercase, accent-free string, so `ilike` finds "Tríceps Testa" whether the
-- user types "triceps", "tríceps" or the English "Lying Triceps Extension" -
-- searching names->>'pt' directly would need an `or` per locale built into the
-- query string, and would miss unaccented typing entirely.
--
-- It reads every value of the blob rather than named locales, so adding a
-- locale stays an import re-run with no migration - the whole point of keying
-- names by locale. That needs the two immutable wrappers below: a generated
-- column can only call immutable functions, and unaccent() is merely stable
-- (it depends on a dictionary that could in principle be redefined), while
-- jsonb_each_text is set-returning and can't be inlined into the expression.
create extension if not exists unaccent;

create or replace function immutable_unaccent(value text)
returns text
language sql
immutable
strict
set search_path = public, extensions
as $$
  select unaccent('unaccent', value);
$$;

create or replace function exercise_search_text(names jsonb)
returns text
language sql
immutable
strict
set search_path = public
as $$
  select immutable_unaccent(lower(coalesce(string_agg(value, ' '), ''))) from jsonb_each_text(names);
$$;

alter table exercises add column if not exists search_text text generated always as (exercise_search_text(names)) stored;

create unique index if not exists exercises_slug_unique_idx on exercises (slug);
create index if not exists exercises_user_id_idx on exercises (user_id);
create index if not exists exercises_primary_muscles_idx on exercises using gin (primary_muscles);
create index if not exists exercises_search_text_idx on exercises (search_text);

-- A workout is one session on one day. `notes` is free text ("senti o ombro").
-- A user can log more than one workout on a date (a two-a-day), so there's no
-- unique constraint on (user_id, performed_date) - the app shows them all.
create table if not exists workouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  performed_date date not null,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists workouts_user_id_performed_date_idx on workouts (user_id, performed_date);

-- A routine is a named, ordered list of exercises ("Treino A - Peito e
-- triceps"). A user's routines form a cycle: the app suggests the one after
-- whichever routine the last routine-backed workout used (see issue #94).
-- `position` is that cycle order, not insertion order.
--
-- Routines are private, like recipes - unlike the exercises catalog they read
-- from. There is no shared/published routine concept.
create table if not exists routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  position integer not null,
  created_at timestamptz not null default now()
);

create index if not exists routines_user_id_position_idx on routines (user_id, position);

-- routine_exercises has no user_id: it inherits the owner of its parent routine,
-- the same shape recipe_ingredients uses. `on delete restrict` on exercise_id
-- matches workout_exercises - a routine referencing a deleted exercise would be
-- a broken routine, so the delete is refused rather than silently emptying it.
create table if not exists routine_exercises (
  id uuid primary key default gen_random_uuid(),
  routine_id uuid not null references routines (id) on delete cascade,
  exercise_id uuid not null references exercises (id) on delete restrict,
  position integer not null,
  created_at timestamptz not null default now()
);

create index if not exists routine_exercises_routine_id_idx on routine_exercises (routine_id);

-- Which routine a workout came from, if any. Nullable on purpose: a one-off
-- workout belongs to no routine and is just as valid - the FAB path from issue
-- #93 still works untouched, and only workouts with a routine_id participate in
-- the cycle.
--
-- `on delete set null` rather than cascade: deleting a routine must not delete
-- the training history performed under it. The workout survives and simply
-- stops naming where it came from, the same call recipes made by leaving their
-- foods row behind.
alter table workouts add column if not exists routine_id uuid references routines (id) on delete set null;

create index if not exists workouts_user_id_routine_id_idx on workouts (user_id, routine_id) where routine_id is not null;

-- Which exercises a workout was made of, in order. `position` is what the user
-- dragged them into, not insertion order.
--
-- The exercise is `on delete restrict`, unlike food_logs' cascade onto foods: a
-- catalog exercise is either imported (nobody can delete it) or user-added, and
-- silently erasing sessions from someone's history because the author of a
-- custom exercise removed it would destroy real training data.
create table if not exists workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references workouts (id) on delete cascade,
  exercise_id uuid not null references exercises (id) on delete restrict,
  position integer not null,
  created_at timestamptz not null default now()
);

-- When the user marked this exercise done, which collapses its card and, once
-- every exercise in the workout has one, is what says the workout is finished
-- (see issue #102). Nullable: null means still in progress, and unmarking is
-- setting it back to null - a mistaken tap must not cost the exercise.
--
-- Deliberately not derived from "has at least one set": those are different
-- facts. One set of a planned four isn't done, and a workout started from a
-- routine (issue #94) is born with the previous session's sets already filled
-- in, so it would count as finished before the user lifts anything.
alter table workout_exercises add column if not exists completed_at timestamptz;

create index if not exists workout_exercises_workout_id_idx on workout_exercises (workout_id);
create index if not exists workout_exercises_exercise_id_idx on workout_exercises (exercise_id);

-- One row per set actually performed: reps plus the load lifted.
--
-- weight_kg allows 0 rather than being null-for-bodyweight: a pull-up and a 0kg
-- barbell row are both "no external load", and a single numeric keeps every
-- volume sum (reps * weight_kg) total-able without a null branch. It's the
-- reason issue #96 counts sets alongside tonnage - bodyweight work sums to 0kg
-- of volume, and only the set count represents it.
create table if not exists workout_sets (
  id uuid primary key default gen_random_uuid(),
  workout_exercise_id uuid not null references workout_exercises (id) on delete cascade,
  position integer not null,
  reps integer not null check (reps > 0),
  weight_kg numeric not null default 0 check (weight_kg >= 0),
  created_at timestamptz not null default now()
);

create index if not exists workout_sets_workout_exercise_id_idx on workout_sets (workout_exercise_id);

-- Keeps exercises.times_logged in sync, mirroring bump_food_times_logged.
-- security definer for the same reason: the logging user doesn't own the
-- (imported, null user_id) exercise row, so exercises' update policy would
-- otherwise block the bump. Counts workout_exercises, not workout_sets - the
-- signal is "how many sessions used this exercise", so adding a fourth set to
-- an exercise you're already doing isn't a second vote for it.
create or replace function bump_exercise_times_logged()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    update exercises set times_logged = times_logged + 1 where id = new.exercise_id;
  elsif tg_op = 'DELETE' then
    update exercises set times_logged = greatest(times_logged - 1, 0) where id = old.exercise_id;
  end if;
  return null;
end;
$$;

drop trigger if exists workout_exercises_bump_times_logged on workout_exercises;
create trigger workout_exercises_bump_times_logged
  after insert or delete on workout_exercises
  for each row execute function bump_exercise_times_logged();

-- Reconcile from workout_exercises (the source of truth), idempotently, the
-- same way foods.times_logged is re-seeded above.
update exercises set times_logged = 0 where times_logged <> 0;
update exercises e
set times_logged = sub.cnt
from (select exercise_id, count(*) as cnt from workout_exercises group by exercise_id) sub
where e.id = sub.exercise_id;

alter table foods enable row level security;
alter table food_logs enable row level security;
alter table water_logs enable row level security;
alter table sleep_logs enable row level security;
alter table recipes enable row level security;
alter table recipe_ingredients enable row level security;
alter table food_favorites enable row level security;
alter table exercises enable row level security;
alter table workouts enable row level security;
alter table workout_exercises enable row level security;
alter table workout_sets enable row level security;
alter table routines enable row level security;
alter table routine_exercises enable row level security;

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

-- Recipes are personal, unlike the foods catalog they read from: only their
-- author lists them. recipe_ingredients has no user_id of its own - it inherits
-- the owner of its parent recipe, so the policy checks that instead of
-- duplicating the column.
drop policy if exists "Users manage their own recipes" on recipes;
create policy "Users manage their own recipes" on recipes
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their own recipe ingredients" on recipe_ingredients;
create policy "Users manage their own recipe ingredients" on recipe_ingredients
  for all
  using (exists (select 1 from recipes where recipes.id = recipe_ingredients.recipe_id and recipes.user_id = auth.uid()))
  with check (exists (select 1 from recipes where recipes.id = recipe_ingredients.recipe_id and recipes.user_id = auth.uid()));

-- Favourites are private, like recipes: the food they point at is shared, but
-- who favourited it is not.
drop policy if exists "Users manage their own food favorites" on food_favorites;
create policy "Users manage their own food favorites" on food_favorites
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- exercises is a shared catalog, on the same terms as foods: anyone
-- authenticated reads every row, only a row's own author can change it.
drop policy if exists "Anyone can read exercises" on exercises;
create policy "Anyone can read exercises" on exercises
  for select
  using (true);

drop policy if exists "Users insert their own exercises" on exercises;
create policy "Users insert their own exercises" on exercises
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users update their own exercises" on exercises;
create policy "Users update their own exercises" on exercises
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users delete their own exercises" on exercises;
create policy "Users delete their own exercises" on exercises
  for delete
  using (auth.uid() = user_id);

-- Workouts are private. workout_exercises and workout_sets carry no user_id of
-- their own - they inherit their workout's owner, so their policies walk up to
-- it rather than duplicating the column, the same shape recipe_ingredients uses.
drop policy if exists "Users manage their own workouts" on workouts;
create policy "Users manage their own workouts" on workouts
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their own workout exercises" on workout_exercises;
create policy "Users manage their own workout exercises" on workout_exercises
  for all
  using (exists (select 1 from workouts where workouts.id = workout_exercises.workout_id and workouts.user_id = auth.uid()))
  with check (exists (select 1 from workouts where workouts.id = workout_exercises.workout_id and workouts.user_id = auth.uid()));

drop policy if exists "Users manage their own workout sets" on workout_sets;
create policy "Users manage their own workout sets" on workout_sets
  for all
  using (
    exists (
      select 1
      from workout_exercises
      join workouts on workouts.id = workout_exercises.workout_id
      where workout_exercises.id = workout_sets.workout_exercise_id and workouts.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1
      from workout_exercises
      join workouts on workouts.id = workout_exercises.workout_id
      where workout_exercises.id = workout_sets.workout_exercise_id and workouts.user_id = auth.uid()
    )
  );

-- Storage bucket for exercise photos, on the same terms as food-images: public
-- read (they're shown in the shared catalog to everyone), authenticated write.
-- Its contents are mirrored from free-exercise-db by the import tool rather
-- than uploaded from the app, so nothing writes here at runtime yet - the
-- insert policy is what lets a user-added exercise carry a photo later.
insert into storage.buckets (id, name, public)
values ('exercise-images', 'exercise-images', true)
on conflict (id) do nothing;

drop policy if exists "Anyone can view exercise images" on storage.objects;
create policy "Anyone can view exercise images" on storage.objects
  for select
  using (bucket_id = 'exercise-images');

drop policy if exists "Authenticated users can upload exercise images" on storage.objects;
create policy "Authenticated users can upload exercise images" on storage.objects
  for insert
  with check (bucket_id = 'exercise-images' and auth.uid() is not null);

-- Routines are private, on the same terms as recipes. routine_exercises walks up
-- to its parent routine's owner rather than duplicating user_id.
drop policy if exists "Users manage their own routines" on routines;
create policy "Users manage their own routines" on routines
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their own routine exercises" on routine_exercises;
create policy "Users manage their own routine exercises" on routine_exercises
  for all
  using (exists (select 1 from routines where routines.id = routine_exercises.routine_id and routines.user_id = auth.uid()))
  with check (exists (select 1 from routines where routines.id = routine_exercises.routine_id and routines.user_id = auth.uid()));
