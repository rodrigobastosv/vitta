import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

import '../../../factories/entities/workout_factory.dart';
import '../../../factories/entities/workout_set_factory.dart';
import '../../../factories/repositories_factories.dart';
import '../../../mocks/datasources_mocks.dart';

void main() {
  test('getDailyWorkoutsInRange groups workouts by their performed day', () async {
    final supabaseWorkoutDataSource = MockSupabaseWorkoutDataSource();
    final from = DateTime(2026, 7);
    final to = DateTime(2026, 7, 31);
    final workouts = [
      WorkoutFactory.build(id: 'a', performedDate: DateTime(2026, 7, 5)),
      WorkoutFactory.build(id: 'b', performedDate: DateTime(2026, 7, 5)),
      WorkoutFactory.build(id: 'c', performedDate: DateTime(2026, 7, 11)),
    ];
    when(() => supabaseWorkoutDataSource.getWorkoutsInRange(from: from, to: to)).thenAnswer((_) async => Success(workouts));
    final repository = RepositoriesFactories.buildWorkoutRepository(supabaseWorkoutDataSource: supabaseWorkoutDataSource);

    final workoutsResult = await repository.getDailyWorkoutsInRange(from: from, to: to);
    final workoutsByDate = workoutsResult.when((_) => null, (value) => value);

    expect(workoutsByDate!.keys, unorderedEquals([DateTime(2026, 7, 5), DateTime(2026, 7, 11)]));
    expect(workoutsByDate[DateTime(2026, 7, 5)]!.workouts, hasLength(2));
  });

  test('getExerciseProgression groups sessions by day and orders the points chronologically', () async {
    final supabaseWorkoutDataSource = MockSupabaseWorkoutDataSource();
    final sessions = <(DateTime, List<WorkoutSet>)>[
      (DateTime(2026, 7, 10, 8), [WorkoutSetFactory.build(id: 'a')]),
      (DateTime(2026, 7, 3, 18), [WorkoutSetFactory.build(id: 'b')]),
      (DateTime(2026, 7, 3, 9), [WorkoutSetFactory.build(id: 'c')]),
    ];
    when(() => supabaseWorkoutDataSource.getSessionsForExercise(exerciseId: 'ex-1')).thenAnswer((_) async => Success(sessions));
    final repository = RepositoriesFactories.buildWorkoutRepository(supabaseWorkoutDataSource: supabaseWorkoutDataSource);

    final progressionResult = await repository.getExerciseProgression(exerciseId: 'ex-1');
    final progression = progressionResult.when((_) => null, (value) => value);

    expect(progression!.points.map((point) => point.date), [DateTime(2026, 7, 3), DateTime(2026, 7, 10)]);
    expect(progression.points.first.sets.map((set) => set.id), ['b', 'c']);
  });

  test('getExerciseProgression forwards a datasource failure', () async {
    final supabaseWorkoutDataSource = MockSupabaseWorkoutDataSource();
    when(
      () => supabaseWorkoutDataSource.getSessionsForExercise(exerciseId: 'ex-1'),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final repository = RepositoriesFactories.buildWorkoutRepository(supabaseWorkoutDataSource: supabaseWorkoutDataSource);

    final progressionResult = await repository.getExerciseProgression(exerciseId: 'ex-1');

    expect(progressionResult.when((error) => error.message, (_) => null), 'offline');
  });
}
