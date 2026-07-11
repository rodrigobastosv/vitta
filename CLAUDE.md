# Vitta

Lifestyle companion app: diet and workout tracking. Flutter, SDK ^3.10.7. No backend/data source chosen yet — currently a scaffold + design system with placeholder feature pages.

## Architecture

Clean Architecture, without repository/datasource interfaces and without a separate data-model layer — one concrete class per responsibility, no `Impl` suffixes:

```
lib/app/
  core/            DI (get_it), navigation extensions — grows as features need networking/error handling/logging
  data/<feature>/   Repository (concrete class), datasources/, datasources/requests/ — not created yet
  domain/<feature>/ Entities, use cases (plain classes with a `call` method) — not created yet
  design_system/    VT-prefixed tokens, themes and components
  presentation/     Pages (Cubit + VTPage), routing
```

`data/`/`domain/` don't exist yet — no feature has a concrete data source. When the diet feature's data source is chosen (a public nutrition API vs. local persistence), add `core/error` (`Result`/`VTError`), `core/http` (if remote) or a local persistence layer, and `core/logging`, following the same shape as this project's sibling `dofus_buddy` (see its CLAUDE.md for the exact pattern: `DBHttpRequest`/`DBHttpClient`/`Result<F, S>`). Entities should double as the wire format (`@JsonSerializable` directly on the entity, generated via `build_runner`) rather than introducing a separate model layer — only add one if a feature's wire format and domain shape genuinely diverge.

A domain use case will depend directly on the concrete repository class from `data/`, e.g.:

```dart
class LogMealUseCase {
  LogMealUseCase({required DietRepository dietRepository}) : _dietRepository = dietRepository;
  final DietRepository _dietRepository;
  Future<Result<VTError, Meal>> call({required Meal meal}) => _dietRepository.logMeal(meal: meal);
}
```

## Dependency injection

`GetIt.instance` is aliased as `G` (`lib/app/core/di/dependencies.dart`). Register dependencies in `setupDependencies()`, called once from `main()`. Resolve with `G<Type>()`. Currently only `AppCubit` is registered.

## State management

`flutter_bloc` Cubits. Pages use `VTPage<C, S>` (`lib/app/presentation/general/vt_page.dart`): it wires `BlocBuilder` and hands the cubit + state straight to the builder, so pages never call `context.read` for their own cubit inside `build`.

## Design system

Everything under `lib/app/design_system` is prefixed `VT` (`VTColors`, `VTSpacing`, `VTRadius`, `VTTextStyles`, `VTTheme`, `VTGap`, `VTCard`, `VTPrimaryButton`, `VTEmptyState`, `VTErrorState`, `VTLoadingIndicator`, `VTFeatureTile`) so design-system pieces are always identifiable at a glance. Never use raw Material spacing/colors/text styles in a page when a `VT` token or component exists — add one if it's missing instead of reaching for `SizedBox`/`Colors.*` directly. Component set is sized to what's actually rendered — add a new one only once a page needs it (e.g. a network image or search field component once the diet feature has food images/search).

Palette: forest green primary (health, nutrition), coral-orange secondary (energy, warmth), warm-neutral surfaces. Typography: Poppins for headings, Inter for body text (both via `google_fonts`).

## Navigation

No bottom nav bar — `HomePage` (`/`) is the single entrypoint: a settings action in the `AppBar` plus a grid of `VTFeatureTile`s (one per feature) that push their feature route. Each feature page owns its own `Scaffold`/`AppBar`; there is no shared shell.

Routes are never referenced by raw path string outside of `app_router.dart`. `AppRoute` (`lib/app/presentation/routing/app_route.dart`) is an enum pairing each route's name with its path; `GoRoute`s are declared with both `path: route.path` and `name: route.name`. Elsewhere, navigate with the `BuildContext` extension in `lib/app/core/navigation/navigation_extensions.dart`: `context.pushRoute(.diet)` / `context.goRoute(.settings)`, optionally with `extra:` for arguments. Add a new feature by adding a case to `AppRoute`, a `GoRoute` in `app_router.dart`, and a tile to `HomePage`.

## App-level state

`AppCubit` (`lib/app/cubit/app_cubit.dart`) holds cross-cutting app state — currently just the locale override (`AppState.locale`, null = follow system) and `themeMode`. It's a GetIt singleton provided once at the root in `main.dart` via `BlocProvider.value(value: G<AppCubit>(), ...)` wrapping `MaterialApp.router`, so any page can reach it with `context.read<AppCubit>()`. `SettingsPage` is its only consumer today, changing locale/theme through `RadioGroup`s. The choice is in-memory only — it resets on app restart until local persistence is added.

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

- `test/mocks/`: one file per layer (`repositories_mocks.dart`, `use_cases_mocks.dart`, ...), each a one-line `class MockX extends Mock implements X {}` — not created yet, add once a repository/use case exists.
- `test/factories/`: builders with sensible defaults and named-optional overrides. Entity factories live in `test/factories/entities/`; use case and cubit factories in `test/factories/use_cases_factories.dart` / `cubits_factories.dart` — only add a cubit factory once the cubit takes constructor dependencies worth defaulting (`AppCubit` doesn't, so it's built inline in its test).
- Cubits: `bloc_test`'s `blocTest`, building the cubit (and any mocks it needs) inside `build:`.

## Growing this file

This file is intentionally thin right now — it covers only the scaffold and design system. Add a section whenever a new pattern is established: the diet feature's data source and networking layer, local persistence, a new design-system category, the workout feature, etc.
