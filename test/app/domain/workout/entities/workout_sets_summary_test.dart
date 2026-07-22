import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/workout/entities/workout_sets_summary.dart';
import 'package:vitta/l10n/arb/app_localizations_en.dart';

import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('groups identical sets into the n×reps · load form', () {
    final sets = [
      WorkoutSetFactory.build(id: 's1'),
      WorkoutSetFactory.build(id: 's2', position: 1),
      WorkoutSetFactory.build(id: 's3', position: 2),
      WorkoutSetFactory.build(id: 's4', position: 3),
    ];

    expect(WorkoutSetsSummary.format(sets: sets, unitSystem: UnitSystem.metric, l10n: l10n), '4×10 · 40 kg');
  });

  test('falls back to a set count and top load when the sets differ', () {
    final sets = [WorkoutSetFactory.build(id: 's1'), WorkoutSetFactory.build(id: 's2', position: 1, reps: 8, weightKg: 45)];

    expect(WorkoutSetsSummary.format(sets: sets, unitSystem: UnitSystem.metric, l10n: l10n), '2 sets · 45 kg');
  });

  test("converts the load into the reader's unit system", () {
    final sets = [WorkoutSetFactory.build(weightKg: 90)];

    expect(WorkoutSetsSummary.format(sets: sets, unitSystem: UnitSystem.imperial, l10n: l10n), '1×10 · 198.4 lb');
  });

  test('shows bodyweight rather than a zero load', () {
    final sets = [WorkoutSetFactory.build(id: 's1', reps: 12, weightKg: 0), WorkoutSetFactory.build(id: 's2', position: 1, reps: 12, weightKg: 0)];

    expect(WorkoutSetsSummary.format(sets: sets, unitSystem: UnitSystem.metric, l10n: l10n), '2×12 · Bodyweight');
  });

  test('is null for an exercise with no previous sets', () {
    expect(WorkoutSetsSummary.format(sets: const [], unitSystem: UnitSystem.metric, l10n: l10n), isNull);
  });

  test('sums cardio efforts into total time and distance', () {
    final sets = [
      WorkoutSetFactory.cardio(id: 's1'),
      WorkoutSetFactory.cardio(id: 's2', durationSeconds: 300, distanceMeters: 1000),
    ];

    expect(WorkoutSetsSummary.format(sets: sets, unitSystem: UnitSystem.metric, l10n: l10n), '30 min · 6 km');
  });

  test('omits distance from a cardio summary when none was logged', () {
    final sets = [WorkoutSetFactory.cardio(durationSeconds: 1200, distanceMeters: null)];

    expect(WorkoutSetsSummary.format(sets: sets, unitSystem: UnitSystem.metric, l10n: l10n), '20 min');
  });
}
