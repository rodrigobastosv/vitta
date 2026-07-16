import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression_point.dart';

import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('records report the heaviest load and best estimated 1RM across every session', () {
    final progression = ExerciseProgression(
      points: [
        ExerciseProgressionPoint(date: DateTime(2026, 7), sets: [WorkoutSetFactory.build(reps: 5, weightKg: 100)]),
        ExerciseProgressionPoint(date: DateTime(2026, 7, 8), sets: [WorkoutSetFactory.build(reps: 12, weightKg: 90)]),
      ],
    );

    expect(progression.heaviestWeightKg, 100);
    expect(progression.bestEstimatedOneRepMax, closeTo(90 * (1 + 12 / 30), 1e-9));
    expect(progression.latest?.date, DateTime(2026, 7, 8));
    expect(progression.hasData, isTrue);
  });

  test('an empty progression has no data and no latest point', () {
    const progression = ExerciseProgression(points: []);

    expect(progression.hasData, isFalse);
    expect(progression.latest, isNull);
    expect(progression.heaviestWeightKg, 0);
    expect(progression.bestEstimatedOneRepMax, 0);
  });
}
