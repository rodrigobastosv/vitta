import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/session_progress.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('an exercise never trained before reads as a first time, not as an improvement', () {
    final progress = SessionProgress(
      exercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
      previousSets: const [],
    );

    expect(progress.isFirstTime, isTrue);
    expect(progress.direction, SessionProgressDirection.first);
  });

  test('more volume than last time is up', () {
    final progress = SessionProgress(
      exercise: WorkoutExerciseFactory.build(
        sets: [WorkoutSetFactory.build(id: 'a', weightKg: 50), WorkoutSetFactory.build(id: 'b', weightKg: 50)],
      ),
      previousSets: [WorkoutSetFactory.build(id: 'old', weightKg: 50)],
    );

    expect(progress.direction, SessionProgressDirection.up);
    expect(progress.volumeDeltaKg, 500);
  });

  test('the same sets as last time is flat, not down', () {
    final sets = [WorkoutSetFactory.build()];
    final progress = SessionProgress(exercise: WorkoutExerciseFactory.build(sets: sets), previousSets: sets);

    expect(progress.direction, SessionProgressDirection.flat);
    expect(progress.volumeDeltaKg, 0);
  });

  test('less volume than last time is down', () {
    final progress = SessionProgress(
      exercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build(reps: 8)]),
      previousSets: [WorkoutSetFactory.build(id: 'old')],
    );

    expect(progress.direction, SessionProgressDirection.down);
  });

  test('a heavier top set is reported even when the volume moved', () {
    final progress = SessionProgress(
      exercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build(reps: 8, weightKg: 60)]),
      previousSets: [WorkoutSetFactory.build(id: 'old', weightKg: 50)],
    );

    expect(progress.heaviestDeltaKg, 10);
  });

  // Cardio has no volume at all, so comparing tonnage would call every run flat.
  test('cardio is compared on time, not on tonnage', () {
    final exercise = ExerciseFactory.build(category: ExerciseCategory.cardio);
    final progress = SessionProgress(
      exercise: WorkoutExerciseFactory.build(exercise: exercise, sets: [WorkoutSetFactory.cardio(durationSeconds: 1800)]),
      previousSets: [WorkoutSetFactory.cardio(id: 'old', durationSeconds: 1200)],
    );

    expect(progress.volumeDeltaKg, 0);
    expect(progress.durationDeltaSeconds, 600);
    expect(progress.direction, SessionProgressDirection.up);
  });

  test('a shorter run than last time is down', () {
    final exercise = ExerciseFactory.build(category: ExerciseCategory.cardio);
    final progress = SessionProgress(
      exercise: WorkoutExerciseFactory.build(exercise: exercise, sets: [WorkoutSetFactory.cardio(durationSeconds: 600)]),
      previousSets: [WorkoutSetFactory.cardio(id: 'old', durationSeconds: 1200)],
    );

    expect(progress.direction, SessionProgressDirection.down);
  });
}
