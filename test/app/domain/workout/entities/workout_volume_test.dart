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

  group('Workout.isComplete', () {
    test('is true only once every exercise is marked done', () {
      final workout = WorkoutFactory.build(
        exercises: [
          WorkoutExerciseFactory.build(id: 'we-1', completedAt: DateTime(2026, 7, 20)),
          WorkoutExerciseFactory.build(id: 'we-2', completedAt: DateTime(2026, 7, 20)),
        ],
      );

      expect(workout.isComplete, isTrue);
    });

    test('one unfinished exercise keeps the workout unfinished', () {
      final workout = WorkoutFactory.build(
        exercises: [
          WorkoutExerciseFactory.build(id: 'we-1', completedAt: DateTime(2026, 7, 20)),
          WorkoutExerciseFactory.build(id: 'we-2'),
        ],
      );

      expect(workout.isComplete, isFalse);
    });

    test('an empty workout is never complete - nothing was finished', () {
      expect(WorkoutFactory.build().isComplete, isFalse);
    });

    test('having sets does not mean done: a routine pre-fills sets before anything is lifted', () {
      final workout = WorkoutFactory.build(
        exercises: [
          WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
        ],
      );

      expect(workout.isComplete, isFalse);
    });
  });
}
