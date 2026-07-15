import 'package:flutter_test/flutter_test.dart';

import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  group('WorkoutVolume', () {
    test('sums volume as reps times load across every set', () {
      final workoutExercise = WorkoutExerciseFactory.build(
        sets: [
          WorkoutSetFactory.build(),
          WorkoutSetFactory.build(id: 'set-2', reps: 8, weightKg: 50),
        ],
      );

      expect(workoutExercise.volumeKg, 800);
      expect(workoutExercise.totalSets, 2);
      expect(workoutExercise.totalReps, 18);
      expect(workoutExercise.heaviestWeightKg, 50);
    });

    test('counts a bodyweight set in reps and sets but contributes no volume', () {
      final workoutExercise = WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build(reps: 12, weightKg: 0)]);

      expect(workoutExercise.volumeKg, 0);
      expect(workoutExercise.totalSets, 1);
      expect(workoutExercise.totalReps, 12);
    });

    test('a workout folds over the flattened sets of every exercise', () {
      final workout = WorkoutFactory.build(
        exercises: [
          WorkoutExerciseFactory.build(
            id: 'we-1',
            sets: [WorkoutSetFactory.build(id: 's1')],
          ),
          WorkoutExerciseFactory.build(
            id: 'we-2',
            sets: [WorkoutSetFactory.build(id: 's2', reps: 5, weightKg: 100)],
          ),
        ],
      );

      expect(workout.volumeKg, 900);
      expect(workout.totalSets, 2);
    });
  });
}
