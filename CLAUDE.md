# Vitta

Lifestyle companion app: diet and workout tracking. Flutter, SDK ^3.10.7.

## Backend

Supabase (Postgres). Chosen over Firebase because the diet domain is inherently relational — a day's macro totals are a `SUM()`/`GROUP BY` over `food_logs` joined to `foods`, which Postgres does natively; Firestore would push that aggregation into the client. `supabase_flutter` talks to it directly from the app (no custom backend server).

- `supabase/schema.sql`: source of truth for the `foods` and `food_logs` tables, run manually in the Supabase SQL editor (no migration tooling yet). Both tables have row-level security scoped to `auth.uid()`, so each user only ever sees their own rows.
- Auth is anonymous (`signInAnonymously`, wired in `lib/app/bootstrap.dart`) so RLS has a stable `user_id` without building a login UI yet. Swapping in real accounts later means adding email/OAuth sign-in on top of the same anonymous-session-per-device bootstrap — existing anonymous data can be linked via Supabase's `linkIdentity`.
- `main()` only calls `bootstrap()` (dotenv, Supabase init, anonymous sign-in, `setupDependencies()`) and `runApp()` — infrastructure bootstrap is deliberately kept out of `AppCubit`/widget code so it stays a single, synchronously-ordered sequence and `AppCubit` stays pure presentation state.
- Credentials live in a gitignored `.env` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`), loaded via `flutter_dotenv` and read through `lib/app/core/env/env.dart`. Copy `.env.example` to `.env` and fill in a real project's values — the placeholder committed values won't connect to anything.

## Food data

No proprietary food database. Foods are sourced from the [Open Food Facts](https://world.openfoodfacts.org) public API at search time (`OpenFoodFactsDataSource`, `lib/app/data/diet/datasources/`) rather than mirrored locally — the full OFF export is several GB and would dwarf Supabase's free-tier storage. A search result is only persisted (into the user's own `foods` row) once they actually log it; `LogFoodUseCase` does the save-then-log in one step for any `Food` without an `id`. Users can also add a fully custom food (name + macros per 100g) through the same flow — see `CustomFoodSheet`. There is deliberately no shared/global food catalog yet: every user's `foods` table is scoped to them by RLS, so the same product gets re-imported per user rather than deduplicated across accounts.

## Architecture

Clean Architecture, without repository/datasource interfaces and without a separate data-model layer — one concrete class per responsibility, no `Impl` suffixes:

```
lib/app/
  core/            DI (get_it), navigation extensions, error (Result/VTError), http, env
  data/<feature>/   Repository (concrete class), datasources/, datasources/requests/
  domain/<feature>/ Entities, use cases (plain classes with a `call` method)
  design_system/    VT-prefixed tokens, themes and components
  presentation/     Pages (Cubit + VTPage), routing
```

`data/diet/` and `domain/diet/` are the first feature built out this way, composing two datasources behind one `DietRepository`: `SupabaseDietDataSource` (persistence) and `OpenFoodFactsDataSource` (remote search, via `core/http`'s `VTHttpClient`). Entities double as the wire format for Supabase rows (plain `fromRow`/`toJson`-shaped mapping in the datasource, no `@JsonSerializable`/`build_runner` — Supabase's client already returns decoded maps, so generated (de)serialization would just add ceremony). Follow this same shape for the next feature (workout): one repository per feature composing whatever datasources it needs, entities mapped by hand in the datasource.

A domain use case depends directly on the concrete repository class from `data/`, e.g.:

```dart
class LogFoodUseCase {
  LogFoodUseCase({required DietRepository dietRepository}) : _dietRepository = dietRepository;
  final DietRepository _dietRepository;
  Future<Result<VTError, FoodLog>> call({required Food food, ...}) => _dietRepository.logFood(...);
}
```

One deliberate exception to "no interfaces": the thin adapter that directly wraps a third-party SDK gets an abstract class + one concrete implementation, so datasources depend on the abstraction rather than the vendor's client type — that's the actual swappable boundary (e.g. `core/storage/local_storage_service.dart`'s `LocalStorageService`/`HiveLocalStorageService`; `SupabaseService` follows the same shape). Repositories/datasources/use cases above that boundary stay concrete-only as usual.

## Dependency injection

`GetIt.instance` is aliased as `G` (`lib/app/core/di/dependencies.dart`). Register dependencies in `setupDependencies()`, called once from `bootstrap()`. Resolve with `G<Type>()`.

## Local storage

`hive_ce` (+ `hive_ce_flutter` for `Hive.initFlutter()`) for anything that must survive an app restart but doesn't belong in Supabase (device-local preferences, not user data), sitting behind `core/storage/local_storage_service.dart`'s `LocalStorageService` (`get<T>`/`put<T>`/`delete`) — datasources never import `package:hive_ce` directly, only `HiveLocalStorageService`'s constructor does. One shared `app` `Box<dynamic>`, opened once in `bootstrap()` and wrapped in a single `HiveLocalStorageService` registered in DI (opening a box is async, DI registration isn't) — not one box/service per feature. Each feature still gets its own local datasource class (concrete, no interface, same shape as a feature's Supabase datasource) depending on `LocalStorageService`; keys are prefixed with the feature name (e.g. `SettingsLocalDataSource`'s `settings.locale`, `settings.themeMode` in `data/settings/settings_local_datasource.dart`) so datasources can't collide with each other in the shared box. Primitives only (`String`, `int`, `bool`, ...) — no `TypeAdapter`/`build_runner`. `AppCubit` reads its initial state from `SettingsLocalDataSource` synchronously at construction and writes through on every change. The next feature that needs local-only storage (e.g. onboarding-seen, unit system) gets its own `data/<feature>/<feature>_local_datasource.dart` depending on `LocalStorageService`, with its own key prefix — don't add unrelated state to `SettingsLocalDataSource`.

Tests exercise `HiveLocalStorageService` against a real Hive box in a temp directory (`Hive.init(tempDir.path)`, no platform channels needed) rather than mocking it — see `test/app/core/storage/hive_local_storage_service_test.dart`, `test/app/data/settings/settings_local_datasource_test.dart`, and `test/widget_test.dart`.

## State management

`flutter_bloc` Cubits. Pages use `VTPage<C, S>` (`lib/app/presentation/general/vt_page.dart`): it wires `BlocBuilder` and hands the cubit + state straight to the builder, so pages never call `context.read` for their own cubit inside `build`.

## Design system

Everything under `lib/app/design_system` is prefixed `VT` (`VTColors`, `VTSpacing`, `VTRadius`, `VTTextStyles`, `VTTheme`, `VTGap`, `VTCard`, `VTPrimaryButton`, `VTEmptyState`, `VTErrorState`, `VTLoadingIndicator`, `VTFeatureTile`) so design-system pieces are always identifiable at a glance. Never use raw Material spacing/colors/text styles in a page when a `VT` token or component exists — add one if it's missing instead of reaching for `SizedBox`/`Colors.*` directly. Component set is sized to what's actually rendered — add a new one only once a page needs it (e.g. a network image or search field component once the diet feature has food images/search).

Palette: forest green primary (health, nutrition), coral-orange secondary (energy, warmth), warm-neutral surfaces. Typography: Poppins for headings, Inter for body text (both via `google_fonts`).

## Navigation

No bottom nav bar — `HomePage` (`/`) is the single entrypoint: a settings action in the `AppBar` plus a grid of `VTFeatureTile`s (one per feature) that push their feature route. Each feature page owns its own `Scaffold`/`AppBar`; there is no shared shell.

Routes are never referenced by raw path string outside of `app_router.dart`. `AppRoute` (`lib/app/presentation/routing/app_route.dart`) is an enum pairing each route's name with its path; `GoRoute`s are declared with both `path: route.path` and `name: route.name`. Elsewhere, navigate with the `BuildContext` extension in `lib/app/core/navigation/navigation_extensions.dart`: `context.pushRoute(.diet)` / `context.goRoute(.settings)`, optionally with `extra:` for arguments. Add a new feature by adding a case to `AppRoute`, a `GoRoute` in `app_router.dart`, and a tile to `HomePage`.

## App-level state

`AppCubit` (`lib/app/cubit/app_cubit.dart`) holds cross-cutting app state — currently just the locale override (`AppState.locale`, null = follow system) and `themeMode`. It's a GetIt singleton provided once at the root in `main.dart` via `BlocProvider.value(value: G<AppCubit>(), ...)` wrapping `MaterialApp.router`, so any page can reach it with `context.read<AppCubit>()`. `SettingsPage` is its only consumer today, changing locale/theme through `RadioGroup`s. Persisted via `AppLocalDataSource` (see Local storage) — survives app restart.

## Internationalization

Standard Flutter `gen-l10n` (not a custom solution). ARB files live in `lib/l10n/arb/` (`app_en.arb` is the template, plus `app_pt.arb`). Never hardcode user-facing strings — add a key to both ARB files and read it via `AppLocalizations.of(context)`. Run `flutter gen-l10n` (or `flutter pub get`, which triggers it) after editing an ARB file. Add more locales the same way dofus_buddy added `fr` — a new ARB file plus the corresponding `RadioListTile` in `SettingsPage`.

## Code style

- No comments. Code must be self-explanatory through naming; if it isn't, restructure it rather than annotate it.
- No variables named `result` (or similarly generic — `data`, `response`, `value` as a local var name). Name it after what it actually holds. Prefer destructuring the value straight out of a pattern (`Success(value: final meal)`) over binding the whole `Result` to a throwaway name first.
- Use the dot-shorthand operator wherever the target type is inferable (`.center`, `.w700`, `.light`).
- `flutter analyze` must report zero issues (including `info`-level lints) before considering a change done.
- Lint rules are the explicit list in `analysis_options.yaml`, carried over from the dofus_buddy project.

## Testing

Mirrors `lib/`. No `late` variables — build dependencies inline or through factories.

- `test/mocks/`: one file per layer (`repositories_mocks.dart`, `use_cases_mocks.dart`, `datasources_mocks.dart`, ...), each a one-line `class MockX extends Mock implements X {}`.
- `test/factories/`: builders with sensible defaults and named-optional overrides. Entity factories live in `test/factories/entities/`; use case and cubit factories in `test/factories/use_cases_factories.dart` / `cubits_factories.dart` — only add a cubit factory once the cubit takes constructor dependencies worth defaulting.
- Cubits: `bloc_test`'s `blocTest`, building the cubit (and any mocks it needs) inside `build:`.

## Growing this file

This file is intentionally thin right now — it covers only the scaffold and design system. Add a section whenever a new pattern is established: the diet feature's data source and networking layer, local persistence, a new design-system category, the workout feature, etc.
