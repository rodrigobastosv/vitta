import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/exercise_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  blocTest<ExerciseSearchCubit, ExerciseSearchState>(
    'emits results for a query',
    build: () {
      final searchExercisesUseCase = MockSearchExercisesUseCase();
      when(
        () => searchExercisesUseCase(
          query: any(named: 'query'),
          muscleGroup: any(named: 'muscleGroup'),
        ),
      ).thenAnswer((_) async => Success([ExerciseFactory.build()]));
      return CubitsFactories.buildExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase);
    },
    act: (cubit) => cubit.search('supino'),
    expect: () => [
      isA<ExerciseSearchState>().having((state) => state.query, 'query', 'supino'),
      isA<ExerciseSearchState>().having((state) => state.results, 'results', hasLength(1)),
    ],
  );

  blocTest<ExerciseSearchCubit, ExerciseSearchState>(
    'a search that matches nothing is an empty list, not the idle null',
    build: () {
      final searchExercisesUseCase = MockSearchExercisesUseCase();
      when(
        () => searchExercisesUseCase(
          query: any(named: 'query'),
          muscleGroup: any(named: 'muscleGroup'),
        ),
      ).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase);
    },
    act: (cubit) => cubit.search('zzzz'),
    expect: () => [
      isA<ExerciseSearchState>().having((state) => state.query, 'query', 'zzzz'),
      isA<ExerciseSearchState>().having((state) => state.results, 'results', isEmpty),
    ],
  );

  blocTest<ExerciseSearchCubit, ExerciseSearchState>(
    'clearing the muscle filter re-runs the search with no filter',
    build: () {
      final searchExercisesUseCase = MockSearchExercisesUseCase();
      when(
        () => searchExercisesUseCase(
          query: any(named: 'query'),
          muscleGroup: any(named: 'muscleGroup'),
        ),
      ).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase);
    },
    act: (cubit) async {
      await cubit.changeMuscleGroup(MuscleGroup.chest);
      await cubit.changeMuscleGroup(null);
    },
    expect: () => [
      isA<ExerciseSearchState>().having((state) => state.muscleGroup, 'muscleGroup', MuscleGroup.chest),
      isA<ExerciseSearchState>().having((state) => state.results, 'results', isEmpty),
      isA<ExerciseSearchState>().having((state) => state.muscleGroup, 'muscleGroup', isNull),
    ],
  );

  blocPresentationTest<ExerciseSearchCubit, ExerciseSearchState, ExerciseSearchPresentationEvent>(
    'surfaces a failed search as an error event',
    build: () {
      final searchExercisesUseCase = MockSearchExercisesUseCase();
      when(
        () => searchExercisesUseCase(
          query: any(named: 'query'),
          muscleGroup: any(named: 'muscleGroup'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase);
    },
    act: (cubit) => cubit.search('supino'),
    expectPresentation: () => [
      isA<ExerciseSearchShowLoading>(),
      isA<ExerciseSearchHideLoading>(),
      isA<ExerciseSearchError>().having((event) => event.message, 'message', 'offline'),
    ],
  );

  test('typing searches on its own, once the keystrokes stop', () async {
    final searchExercisesUseCase = MockSearchExercisesUseCase();
    when(() => searchExercisesUseCase(query: any(named: 'query'), muscleGroup: any(named: 'muscleGroup')))
        .thenAnswer((_) async => Success([ExerciseFactory.build()]));
    final cubit = CubitsFactories.buildExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase);

    cubit
      ..queryChanged('sup')
      ..queryChanged('supi')
      ..queryChanged('supino');

    verifyNever(() => searchExercisesUseCase(query: any(named: 'query'), muscleGroup: any(named: 'muscleGroup')));

    await Future<void>.delayed(const Duration(milliseconds: 500));

    verify(() => searchExercisesUseCase(query: 'supino', muscleGroup: any(named: 'muscleGroup'))).called(1);
    await cubit.close();
  });

  test('a one-letter query never reaches the network', () async {
    final searchExercisesUseCase = MockSearchExercisesUseCase();
    final cubit = CubitsFactories.buildExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase);

    cubit.queryChanged('s');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    verifyNever(() => searchExercisesUseCase(query: any(named: 'query'), muscleGroup: any(named: 'muscleGroup')));
    await cubit.close();
  });
}
