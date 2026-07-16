import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';

import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('volume and set count fold across every workout of the day', () {
    final dailyWorkout = DailyWorkout(
      date: DateTime(2026, 7, 15),
      workouts: [
        WorkoutFactory.build(
          id: 'morning',
          exercises: [
            WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build(reps: 12, weightKg: 50)]),
          ],
        ),
        WorkoutFactory.build(
          id: 'evening',
          exercises: [
            WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build(reps: 5, weightKg: 100)]),
          ],
        ),
      ],
    );

    expect(dailyWorkout.volumeKg, 12 * 50 + 5 * 100);
    expect(dailyWorkout.totalSets, 2);
    expect(dailyWorkout.hasData, isTrue);
  });

  test('a day with no workouts has no data', () {
    final dailyWorkout = DailyWorkout(date: DateTime(2026, 7, 15), workouts: const []);
    expect(dailyWorkout.hasData, isFalse);
    expect(dailyWorkout.volumeKg, 0);
  });
}
