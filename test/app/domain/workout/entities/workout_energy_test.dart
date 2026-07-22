import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('a strength exercise burns MET x weight x its sets time', () {
    final exercise = WorkoutExerciseFactory.build(
      sets: [WorkoutSetFactory.build(id: 'a'), WorkoutSetFactory.build(id: 'b'), WorkoutSetFactory.build(id: 'c')],
    );

    // 3 sets x 120s = 0.1h, at MET 5 and 80 kg.
    expect(exercise.estimatedCalories(bodyWeightKg: 80), closeTo(5 * 80 * 0.1, 0.001));
  });

  test('a cardio effort is timed by what was logged, not by its set count', () {
    final exercise = WorkoutExerciseFactory.build(
      exercise: ExerciseFactory.build(category: ExerciseCategory.cardio),
      sets: [WorkoutSetFactory.cardio(durationSeconds: 1800)],
    );

    // One 30-minute effort at MET 7 and 80 kg - the single set is not worth 120s.
    expect(exercise.estimatedCalories(bodyWeightKg: 80), closeTo(7 * 80 * 0.5, 0.001));
  });

  test('a workout with no sets logged burns nothing', () {
    final workout = WorkoutFactory.build(exercises: [WorkoutExerciseFactory.build()]);

    expect(workout.estimatedCalories(bodyWeightKg: 80), 0);
  });

  test('a heavier body burns more for the same session', () {
    final workout = WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
      ],
    );

    expect(workout.estimatedCalories(bodyWeightKg: 100), greaterThan(workout.estimatedCalories(bodyWeightKg: 60)));
  });

  test('an unknown body weight falls back to the default rather than to zero', () {
    final workout = WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
      ],
    );

    expect(workout.estimatedCalories(bodyWeightKg: null), workout.estimatedCalories(bodyWeightKg: BodyProfile.defaultWeightKg));
    expect(workout.estimatedCalories(bodyWeightKg: null), greaterThan(0));
  });

  test('a workout totals every exercise, whatever mix of categories it holds', () {
    final strength = WorkoutExerciseFactory.build(id: 'strength', sets: [WorkoutSetFactory.build()]);
    final cardio = WorkoutExerciseFactory.build(
      id: 'cardio',
      exercise: ExerciseFactory.build(id: 'exercise-2', category: ExerciseCategory.cardio),
      sets: [WorkoutSetFactory.cardio(id: 'set-2', durationSeconds: 600)],
    );
    final workout = WorkoutFactory.build(exercises: [strength, cardio]);

    expect(
      workout.estimatedCalories(bodyWeightKg: 80),
      closeTo(strength.estimatedCalories(bodyWeightKg: 80) + cardio.estimatedCalories(bodyWeightKg: 80), 0.001),
    );
  });
}
