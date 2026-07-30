import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/domain/workout/entities/workout_region_volume.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('attributes each exercise volume to its primary muscle region and ranks regions by volume', () {
    final workout = WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(
          id: 'bench',
          exercise: ExerciseFactory.build(id: 'bench'),
          sets: [WorkoutSetFactory.build(reps: 5, weightKg: 100)],
        ),
        WorkoutExerciseFactory.build(
          id: 'squat',
          exercise: ExerciseFactory.build(id: 'squat', primaryMuscles: const [MuscleGroup.quadriceps]),
          sets: [WorkoutSetFactory.build(reps: 5, weightKg: 200)],
        ),
      ],
    );

    final split = WorkoutRegionVolume.fromWorkouts([workout]);

    expect(split.volumeOf(BodyRegion.chest), 5 * 100);
    expect(split.volumeOf(BodyRegion.legs), 5 * 200);
    expect(split.totalVolumeKg, 5 * 100 + 5 * 200);
    expect(split.presentRegions, [BodyRegion.legs, BodyRegion.chest]);
    expect(split.shareOf(BodyRegion.legs), closeTo(1000 / 1500, 1e-9));
  });

  test('an all-bodyweight period has no volume data', () {
    final workout = WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build(reps: 12, weightKg: 0)]),
      ],
    );

    expect(WorkoutRegionVolume.fromWorkouts([workout]).hasData, isFalse);
  });

  test('counts sets per region and ranks the worked regions by how many landed there', () {
    final workout = WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(
          id: 'bench',
          exercise: ExerciseFactory.build(id: 'bench'),
          sets: [
            WorkoutSetFactory.build(id: 'a'),
            WorkoutSetFactory.build(id: 'b'),
            WorkoutSetFactory.build(id: 'c'),
          ],
        ),
        WorkoutExerciseFactory.build(
          id: 'curl',
          exercise: ExerciseFactory.build(id: 'curl', primaryMuscles: const [MuscleGroup.biceps]),
          sets: [WorkoutSetFactory.build(id: 'd')],
        ),
      ],
    );

    final split = WorkoutRegionVolume.fromWorkouts([workout]);

    expect(split.setsOf(BodyRegion.chest), 3);
    expect(split.setsOf(BodyRegion.arms), 1);
    expect(split.setsOf(BodyRegion.legs), 0);
    expect(split.workedRegions, [BodyRegion.chest, BodyRegion.arms]);
  });

  test('intensity is relative to the busiest region, and a region nothing touched reads as unworked', () {
    final workout = WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(
          id: 'bench',
          exercise: ExerciseFactory.build(id: 'bench'),
          sets: [
            WorkoutSetFactory.build(id: 'a'),
            WorkoutSetFactory.build(id: 'b'),
            WorkoutSetFactory.build(id: 'c'),
            WorkoutSetFactory.build(id: 'd'),
          ],
        ),
        WorkoutExerciseFactory.build(
          id: 'curl',
          exercise: ExerciseFactory.build(id: 'curl', primaryMuscles: const [MuscleGroup.biceps]),
          sets: [WorkoutSetFactory.build(id: 'e')],
        ),
      ],
    );

    final split = WorkoutRegionVolume.fromWorkouts([workout]);

    expect(split.intensityOf(BodyRegion.chest), 1);
    expect(split.intensityOf(BodyRegion.arms), 0.25);
    expect(split.intensityOf(BodyRegion.legs), 0);
  });

  test('a cardio effort carries no tonnage but still counts as work on its region', () {
    final workout = WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(
          exercise: ExerciseFactory.build(primaryMuscles: const [MuscleGroup.quadriceps]),
          sets: [WorkoutSetFactory.cardio()],
        ),
      ],
    );

    final split = WorkoutRegionVolume.fromWorkouts([workout]);

    expect(split.hasData, isFalse);
    expect(split.presentRegions, isEmpty);
    expect(split.workedRegions, [BodyRegion.legs]);
    expect(split.intensityOf(BodyRegion.legs), 1);
  });
}
