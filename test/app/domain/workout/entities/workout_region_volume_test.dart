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
}
