import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

import '../../../factories/entities/workout_set_factory.dart';
import '../../../factories/repositories_factories.dart';
import '../../../mocks/datasources_mocks.dart';

void main() {
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
