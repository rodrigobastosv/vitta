# Should Vitta have an event bus? (issue #196)

**Recommendation: no.** Do not add a pub/sub event bus. The centralization the issue
asks for — "one place to add all the logic when an event happens" — already exists and
has since issue #46; analytics (#174) was added to it without touching a single call
site, which is the proof. What the survey below *did* find is that the existing
mechanism was stringly-typed and had one real instrumentation hole. Both are fixed
here, and neither needed a new mechanism.

This document is the deliverable of #196. It states what exists, what a bus would add,
what it would cost, and the evidence for each.

## What already exists

`Log.action(AppEvent.x, data: {...})` (`core/services/logging/log.dart`) is a static
facade over one `LoggingService`, which fans every `LogEntry` out to a
`List<LogDestination>`. Today that list is three sinks:

| destination | what it does with an event |
|---|---|
| `ConsoleLogDestination` | `debugPrint`, `kDebugMode` only |
| `SentryLogDestination` | a Sentry breadcrumb, so the last actions ride on any crash |
| `AnalyticsLogDestination` | a GA4 event (and a screen view, for navigation) |

Surveyed at the time of writing: **57 `Log.action` call sites** across **21 cubits**,
naming **53 distinct events**, plus one `Log.navigation` call inside
`LoggingNavigatorObserver` that covers every route change in the app with no per-page
code.

So the two properties an event bus is usually wanted for are already delivered:

- **One dispatch point.** Every action in the app passes through `LoggingService._dispatch`.
- **Add a listener in one place.** `AnalyticsLogDestination` is 43 lines and one entry
  in `setupDependencies`'s list. Nothing above `core/services/` learned that analytics
  exists — no page, cubit or use case gained a dependency for it. That is exactly the
  "add the logic in one centralized place" the issue asks for, already shipped.

There is also a second, unrelated dispatch mechanism: `bloc_presentation`'s
`emitPresentation` + each cubit's own `sealed class XPresentationEvent`. That one is
**typed** and **one cubit to its own page** — deliberately not shared (`P` is per-cubit
precisely so a cubit can grow events without touching anyone else's type). It carries
loading, errors, toasts and one-off navigation. It is not a bus and should not become
one.

## What an event bus would add that `Log` does not

Three things, honestly:

1. **Typed events instead of a name plus an untyped map.** `Log.action` took a raw
   `String` and a `Map<String, Object?>`. A typo made a new GA4 event rather than an
   error, and the catalog of what the app reports existed only as 50-odd string
   literals scattered across cubits.
2. **Cross-cubit reaction.** Nothing today can say "when a food is logged, refresh the
   diet page". `LogDestination` is fan-out to *sinks*, not to *features*.
3. **One place to read the whole catalog.** Answering "what does this app report?"
   required a `grep`.

(1) and (3) are real and are fixed below — **without a bus**, because they are a naming
problem, not a dispatch problem. (2) is the only thing a bus would genuinely add, and
the survey found no demand for it.

### Why (2) is not a real need here

The app already has a mechanism for one screen reacting to something that happened on
another, and it is the navigation stack: a page that changes another page's data pops a
result, and the caller reloads. Nine call sites use it —
`context.pushRoute<bool>(.copyMeals)`, `.mealScan`, `.recipeForm`, `.routineForm`,
`.signIn`/`.signUp`, `.dietIntro`, `.workoutIntro` — plus `WorkoutPage` reloading the
day when the exercise workspace pops.

That is worse than a bus in the abstract and better than one here, for a reason specific
to this app: **Vitta has no shared shell.** `HomePage` is the single entrypoint and each
feature owns its own `Scaffold` (see CLAUDE.md, Navigation), so two cubits are almost
never alive at once, and page cubits are factories that are closed on pop. A bus event
fired at a cubit that no longer exists is either dropped (so the reload never happens
and the bug is invisible) or replayed into a closed cubit — the exact failure
`PresentationCubit`'s `isClosed` guards were added for in #202. The root singletons that
*are* always alive (`AppCubit`, `PremiumCubit`, `RestTimerCubit`) already reach each
other directly.

## What it would cost

- **A second dispatch mechanism next to two that exist.** A contributor asking "where do
  I announce this?" would have three answers — `Log.action`, `emitPresentation`, the bus
  — differing only by convention. The current two split cleanly (a *report* to sinks vs.
  a *presentation* effect to my own page); a bus overlaps both.
- **Indirection between an action and its effect.** Today `Log.action(.foodLogged)` has
  exactly one class of consequence, and it is stated in one file. With a bus, a reader of
  `DietCubit` cannot tell what firing an event does without searching for subscribers —
  and the answer changes when a subscriber is added elsewhere.
- **An easy path to hidden coupling.** This is the real cost. The layering rule (a page
  never reaches past its cubit; a cubit goes through use cases) is enforceable because
  every hop is a constructor dependency you can see. A bus is an ambient channel any
  layer can publish and subscribe on, and the first time someone writes business logic in
  a subscriber, the dependency graph stops describing the app.
- **Testing.** `useMockLog()` works because there is one static seam. A bus needs
  per-test subscriber setup and teardown, and ordering between subscribers becomes a
  thing tests can depend on.

## Evidence from the survey

Four findings, all from reading the actual call sites.

**1. Two screens perform the same action and only one reported it.**
`ExerciseWorkoutCubit` — the exercise workspace, which since #163 is *the* place the app
sends a user to log a set — had **zero** `Log.action` calls, while `WorkoutCubit` (the
day list) reports `workout_set_logged`, `workout_set_updated`, `workout_set_deleted`,
`workout_exercise_completed`/`_reopened`. So GA4's set-logging figures undercounted by
however much traffic went through the workspace, silently, and `workout_finished` had a
funnel with a missing step in front of it.

This is worth stating plainly because it is the strongest argument *against* the issue's
premise: **a bus would not have fixed it.** The gap is not that the app lacked somewhere
to send the event — it is that nobody wrote the line. Centralization does not instrument
anything; a call site does.

**2. The same payload was built by a private copy per cubit.** `WorkoutCubit._setLogData`
shaped a `SetInput` into `{reps, weight_kg}` or `{duration_seconds, distance_meters}`.
Any second reporter of that action would have re-derived the keys and could have drifted.
Fixed by extracting `setInputLogData` (`presentation/general/`) and using it from both.

**3. One payload violates the app's own analytics rule, and the single fan-out is why.**
`premium_offer_unavailable` carries `{'error': error.toString()}` — free text from an
exception, on an event that reports a handled failure, both of which CLAUDE.md's
Analytics section rules out of GA4. It is *right* for the console and the Sentry
breadcrumb, where the message is the whole point, and wrong for the analytics sink. `Log`
has no way to express "this one is for debugging, not measurement", so a payload correct
for two sinks is wrong for the third. Left as-is deliberately (removing it would blind
the debugging path that motivated it), and recorded here because it names the one real
limitation of the current design: **per-destination filtering, not a bus.** If it ever
matters, the fix is a flag on `LogEntry` that `AnalyticsLogDestination` honours — a
field, not a mechanism.

**4. Minor payload drift, no wrong values.** `objective_changed` sends
`objective.wireValue` while `onboarding_goals_set` sends `objective.name`; they happen to
be the same string (`FitnessObjective.wireValue => name`), so nothing is misreported, but
the two spellings should converge if either is touched. `sleep_imported_from_health` is
fired from two paths with different payload shapes (`{count}` and `{count, auto}`), which
is deliberate and fine — `auto` distinguishes them.

Actions still not instrumented at all, listed so the gap is visible rather than
rediscovered: `CustomFoodCubit` (a custom food built, a nutrition label scanned — the
latter being a *paid* per-use feature with no event, whose sibling `MealScanCubit` does
report `meal_logged_from_scan`), and the paywall being opened. Adding those is a product
decision about what to measure, not a defect, so they are deliberately left to the owner
rather than invented here.

## What was implemented

Only the narrow part the evidence supports.

**`AppEvent` (`core/services/logging/app_event.dart`)** — an enum pairing each case with
its `snake_case` wire name, exactly the way `SupabaseTable` pairs a case with its DB name
and `MealType` with its wire value. `Log.action` now takes an `AppEvent` and unwraps
`wireName` itself, the way `SupabaseService.from` unwraps a `SupabaseTable`, so
`LoggingService` stays a generic sink that knows nothing about the app's events and every
existing test that verifies against the service is untouched. All 57 call sites were
converted; every emitted wire name is byte-identical, because renaming one would start a
fresh GA4 event and orphan its history.

`app_event_test.dart` pins that with a **literal** map of case → wire name (deriving both
sides from the enum would pass while the rename it exists to catch went through), asserts
the map covers every case so a new event cannot ship unpinned, asserts uniqueness, and
asserts `AnalyticsParameters.eventName(wireName) == wireName` — so the GA4 sanitizer can
never quietly rewrite a name into something the dashboard doesn't match.

Adding an event is now one enum case plus the `Log.action(.newCase)` on a cubit's success
path. Nothing else about the pipeline changed.

**The `ExerciseWorkoutCubit` gap** is closed, reusing the day list's existing event names
and payload rather than adding new ones — it was reporting the same actions under the
same names or it was reporting nothing. Pinned by `exercise_workout_cubit_test.dart`.

## What was deliberately not built

- **A pub/sub event bus.** For the reasons above: it duplicates a dispatch mechanism that
  already delivers the issue's stated goal, and the one capability it adds
  (cross-feature reaction) has no demand in an app with no shared shell and page-scoped
  cubits.
- **Typed payloads (a class per event).** The obvious next step from a typed name, and it
  was rejected: it would need ~53 payload classes to type maps that are read by exactly
  one line each, and a payload key is already visible on the same line as the event it
  belongs to — where a mistyped *name* was invisible. The keys are also the GA4 parameter
  names, which `AnalyticsParameters` already sanitizes in one place. Revisit only if
  cross-cubit consumers ever appear, which is the case that would make payloads a real
  contract.
- **Making `LoggingService` speak `AppEvent`.** The service is the generic sink half of
  the design; teaching it the app's event catalog would invert that, and every existing
  logging test asserts against its `String` API.
- **New analytics events** for the un-instrumented actions in finding (4). What to
  measure is the owner's call.
