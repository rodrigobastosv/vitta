import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/presentation/pages/routines/routines_cubit.dart';
import 'package:vitta/app/presentation/pages/routines/routines_presentation_event.dart';
import 'package:vitta/app/presentation/pages/routines/routines_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/routine_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(<String, Object?>{}));

  blocTest<RoutinesCubit, RoutinesState>(
    'emits the routines in cycle order',
    build: () {
      final getRoutinesUseCase = MockGetRoutinesUseCase();
      when(getRoutinesUseCase.call).thenAnswer((_) async => Success(RoutineFactory.buildCycle()));
      return CubitsFactories.buildRoutinesCubit(getRoutinesUseCase: getRoutinesUseCase);
    },
    act: (cubit) => cubit.loadRoutines(),
    expect: () => [
      isA<RoutinesState>().having((state) => [for (final routine in state.routines) routine.id], 'routine order', [
        'routine-a',
        'routine-b',
        'routine-c',
      ]),
    ],
  );

  blocPresentationTest<RoutinesCubit, RoutinesState, RoutinesPresentationEvent>(
    'surfaces a failed load as an error event',
    build: () {
      final getRoutinesUseCase = MockGetRoutinesUseCase();
      when(getRoutinesUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildRoutinesCubit(getRoutinesUseCase: getRoutinesUseCase);
    },
    act: (cubit) => cubit.loadRoutines(),
    expectPresentation: () => [
      isA<RoutinesShowLoading>(),
      isA<RoutinesHideLoading>(),
      isA<RoutinesError>().having((event) => event.message, 'message', 'offline'),
    ],
  );

  test('deleting a routine reloads the list so the cycle reflects it', () async {
    useMockLog();
    final getRoutinesUseCase = MockGetRoutinesUseCase();
    final deleteRoutineUseCase = MockDeleteRoutineUseCase();
    when(getRoutinesUseCase.call).thenAnswer((_) async => const Success([]));
    when(() => deleteRoutineUseCase(routineId: any(named: 'routineId'))).thenAnswer((_) async => const Success(null));
    final cubit = CubitsFactories.buildRoutinesCubit(getRoutinesUseCase: getRoutinesUseCase, deleteRoutineUseCase: deleteRoutineUseCase);

    await cubit.deleteRoutine(routineId: 'routine-a');

    verify(getRoutinesUseCase.call).called(1);
  });

  blocTest<RoutinesCubit, RoutinesState>(
    'reordering moves a routine to the reported index and persists the new cycle order',
    build: () {
      final getRoutinesUseCase = MockGetRoutinesUseCase();
      final reorderRoutinesUseCase = MockReorderRoutinesUseCase();
      when(getRoutinesUseCase.call).thenAnswer((_) async => Success(RoutineFactory.buildCycle()));
      when(() => reorderRoutinesUseCase(orderedRoutineIds: any(named: 'orderedRoutineIds'))).thenAnswer((_) async => const Success(null));
      return CubitsFactories.buildRoutinesCubit(getRoutinesUseCase: getRoutinesUseCase, reorderRoutinesUseCase: reorderRoutinesUseCase);
    },
    act: (cubit) async {
      await cubit.loadRoutines();
      await cubit.reorderRoutines(oldIndex: 2, newIndex: 0);
    },
    skip: 1,
    expect: () => [
      isA<RoutinesState>().having((state) => [for (final routine in state.routines) routine.id], 'routine order', [
        'routine-c',
        'routine-a',
        'routine-b',
      ]),
    ],
  );

  test('reordering persists the ids in their new order', () async {
    useMockLog();
    final getRoutinesUseCase = MockGetRoutinesUseCase();
    final reorderRoutinesUseCase = MockReorderRoutinesUseCase();
    when(getRoutinesUseCase.call).thenAnswer((_) async => Success(RoutineFactory.buildCycle()));
    when(() => reorderRoutinesUseCase(orderedRoutineIds: any(named: 'orderedRoutineIds'))).thenAnswer((_) async => const Success(null));
    final cubit = CubitsFactories.buildRoutinesCubit(
      getRoutinesUseCase: getRoutinesUseCase,
      reorderRoutinesUseCase: reorderRoutinesUseCase,
    );
    await cubit.loadRoutines();

    await cubit.reorderRoutines(oldIndex: 0, newIndex: 2);

    verify(() => reorderRoutinesUseCase(orderedRoutineIds: ['routine-b', 'routine-c', 'routine-a'])).called(1);
  });

  test('a failed reorder reverts to the previous order rather than lying about the cycle', () async {
    useMockLog();
    final getRoutinesUseCase = MockGetRoutinesUseCase();
    final reorderRoutinesUseCase = MockReorderRoutinesUseCase();
    when(getRoutinesUseCase.call).thenAnswer((_) async => Success(RoutineFactory.buildCycle()));
    when(
      () => reorderRoutinesUseCase(orderedRoutineIds: any(named: 'orderedRoutineIds')),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final cubit = CubitsFactories.buildRoutinesCubit(
      getRoutinesUseCase: getRoutinesUseCase,
      reorderRoutinesUseCase: reorderRoutinesUseCase,
    );
    await cubit.loadRoutines();

    await cubit.reorderRoutines(oldIndex: 0, newIndex: 2);

    expect([for (final routine in cubit.state.routines) routine.id], ['routine-a', 'routine-b', 'routine-c']);
  });
}
