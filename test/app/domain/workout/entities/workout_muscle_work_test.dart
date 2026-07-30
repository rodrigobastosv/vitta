import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/domain/workout/entities/workout_muscle_work.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('credits every primary muscle of an exercise, not only the first', () {
    final work = WorkoutMuscleWork.fromExercises([
      WorkoutExerciseFactory.build(
        exercise: ExerciseFactory.build(primaryMuscles: const [MuscleGroup.chest, MuscleGroup.shoulders], secondaryMuscles: const []),
        sets: [WorkoutSetFactory.build()],
      ),
    ]);

    expect(work.activeSecondsOf(MuscleGroup.chest), greaterThan(0));
    expect(work.activeSecondsOf(MuscleGroup.shoulders), work.activeSecondsOf(MuscleGroup.chest));
    expect(work.workedMuscles, containsAll([MuscleGroup.chest, MuscleGroup.shoulders]));
  });

  test('credits a secondary muscle at half of a primary one', () {
    final work = WorkoutMuscleWork.fromExercises([
      WorkoutExerciseFactory.build(
        exercise: ExerciseFactory.build(),
        sets: [WorkoutSetFactory.build()],
      ),
    ]);

    expect(work.activeSecondsOf(MuscleGroup.triceps), work.activeSecondsOf(MuscleGroup.chest) * WorkoutMuscleWork.secondaryMuscleShare);
    expect(work.intensityOf(MuscleGroup.chest), 1);
    expect(work.intensityOf(MuscleGroup.triceps), 0.5);
  });

  test('a muscle nothing worked reads as no work and no intensity', () {
    final work = WorkoutMuscleWork.fromExercises([
      WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
    ]);

    expect(work.activeSecondsOf(MuscleGroup.calves), 0);
    expect(work.intensityOf(MuscleGroup.calves), 0);
    expect(work.workedMuscles, isNot(contains(MuscleGroup.calves)));
  });

  test('an exercise with no sets contributes nothing', () {
    final work = WorkoutMuscleWork.fromExercises([WorkoutExerciseFactory.build()]);

    expect(work.hasData, isFalse);
    expect(work.workedMuscles, isEmpty);
    expect(work.workedRegions, isEmpty);
  });

  test('measures a cardio effort by its duration, so it is not one set of nothing', () {
    final strength = WorkoutMuscleWork.fromExercises([
      WorkoutExerciseFactory.build(
        exercise: ExerciseFactory.build(secondaryMuscles: const []),
        sets: [WorkoutSetFactory.build()],
      ),
    ]);
    final run = WorkoutMuscleWork.fromExercises([
      WorkoutExerciseFactory.build(
        exercise: ExerciseFactory.build(
          category: ExerciseCategory.cardio,
          primaryMuscles: const [MuscleGroup.quadriceps],
          secondaryMuscles: const [],
        ),
        sets: [WorkoutSetFactory.cardio(durationSeconds: 1800)],
      ),
    ]);

    expect(run.activeSecondsOf(MuscleGroup.quadriceps), 1800);
    expect(run.activeSecondsOf(MuscleGroup.quadriceps), greaterThan(strength.activeSecondsOf(MuscleGroup.chest)));
  });

  test('ranks muscles and regions by how much work landed on them', () {
    final work = WorkoutMuscleWork.fromWorkouts([
      WorkoutFactory.build(
        exercises: [
          WorkoutExerciseFactory.build(
            id: 'squat',
            exercise: ExerciseFactory.build(id: 'squat', primaryMuscles: const [MuscleGroup.quadriceps], secondaryMuscles: const []),
            sets: [WorkoutSetFactory.build(id: 'a'), WorkoutSetFactory.build(id: 'b'), WorkoutSetFactory.build(id: 'c')],
          ),
          WorkoutExerciseFactory.build(
            id: 'bench',
            exercise: ExerciseFactory.build(id: 'bench', secondaryMuscles: const []),
            sets: [WorkoutSetFactory.build(id: 'd')],
          ),
        ],
      ),
    ]);

    expect(work.workedMuscles, [MuscleGroup.quadriceps, MuscleGroup.chest]);
    expect(work.workedRegions, [BodyRegion.legs, BodyRegion.chest]);
    expect(work.intensityOf(MuscleGroup.chest), closeTo(1 / 3, 0.001));
  });
}
