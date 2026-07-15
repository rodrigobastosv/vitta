import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';
import 'package:vitta/app/presentation/pages/workout/workout_cubit.dart';
import 'package:vitta/app/presentation/pages/workout/workout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/routine_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

/// loadDate loads the routine cycle too, so any test that loads a day has to
/// answer that call. Factories never stub (see CLAUDE.md), hence this helper
/// rather than a stubbed default.
MockGetRoutineCycleUseCase _emptyCycleUseCase() {
  final useCase = MockGetRoutineCycleUseCase();
  when(useCase.call).thenAnswer((_) async => const Success(RoutineCycle(routines: [])));
  return useCase;
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(RoutineFactory.build());
    registerFallbackValue(<String, Object?>{});
  });

  blocTest<WorkoutCubit, WorkoutState>(
    "emits the day's workouts when the load succeeds",
    build: () {
      final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
      when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer(
        (_) async => Success([
          WorkoutFactory.build(
            exercises: [
              WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
            ],
          ),
        ]),
      );
      return CubitsFactories.buildWorkoutCubit(
        getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
        getRoutineCycleUseCase: _emptyCycleUseCase(),
      );
    },
    act: (cubit) => cubit.loadDate(DateTime(2026, 7, 15)),
    expect: () => [isA<WorkoutState>().having((state) => state.volumeKg, 'volumeKg', 400)],
  );

  blocPresentationTest<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
    'shows then hides loading while the day loads',
    build: () {
      final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
      when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildWorkoutCubit(
        getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
        getRoutineCycleUseCase: _emptyCycleUseCase(),
      );
    },
    act: (cubit) => cubit.loadDate(DateTime(2026, 7, 15)),
    expectPresentation: () => [isA<WorkoutShowLoading>(), isA<WorkoutHideLoading>()],
  );

  blocPresentationTest<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
    'reports the failed date on the error event, not whatever date the state holds later',
    build: () {
      final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
      when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildWorkoutCubit(
        getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
        getRoutineCycleUseCase: _emptyCycleUseCase(),
      );
    },
    act: (cubit) => cubit.loadDate(DateTime(2026, 7, 10)),
    expectPresentation: () => [
      isA<WorkoutShowLoading>(),
      isA<WorkoutHideLoading>(),
      isA<WorkoutError>()
          .having((event) => event.message, 'message', 'offline')
          .having((event) => event.date, 'date', DateTime(2026, 7, 10)),
    ],
  );

  test("addExercise creates the day's workout when there is none yet", () async {
    useMockLog();
    final addExerciseToWorkoutUseCase = MockAddExerciseToWorkoutUseCase();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(
      () => addExerciseToWorkoutUseCase(
        date: any(named: 'date'),
        exerciseId: any(named: 'exerciseId'),
        workoutId: any(named: 'workoutId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build()));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      addExerciseToWorkoutUseCase: addExerciseToWorkoutUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
    );

    await cubit.addExercise(ExerciseFactory.build(id: 'exercise-9'));

    // workoutId stays null on an empty day, which is what tells the use case to
    // create the workout before attaching the exercise.
    verify(
      () => addExerciseToWorkoutUseCase(
        date: any(named: 'date'),
        exerciseId: 'exercise-9',
      ),
    ).called(1);
  });

  test('logSet returns the failure to the sheet instead of emitting an error event', () async {
    useMockLog();
    final logSetUseCase = MockLogSetUseCase();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(
      () => logSetUseCase(
        workoutExerciseId: any(named: 'workoutExerciseId'),
        reps: any(named: 'reps'),
        weightKg: any(named: 'weightKg'),
      ),
    ).thenAnswer((_) async => const Failure(VTError(message: 'nope')));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      logSetUseCase: logSetUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
    );

    final loggedResult = await cubit.logSet(workoutExerciseId: 'we-1', reps: 10, weightKg: 40);

    expect(loggedResult, isA<Failure<VTError, void>>());
  });

  test('unitSystem reads settings directly rather than through AppCubit', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings(unitSystem: UnitSystem.imperial));
    final cubit = CubitsFactories.buildWorkoutCubit(getAppSettingsUseCase: getAppSettingsUseCase);

    expect(cubit.unitSystem, UnitSystem.imperial);
  });

  test('a failed cycle load hides the suggestion instead of breaking the day', () async {
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    final getRoutineCycleUseCase = MockGetRoutineCycleUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(getRoutineCycleUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      getRoutineCycleUseCase: getRoutineCycleUseCase,
    );

    await cubit.loadDate(DateTime(2026, 7, 20));

    // The day still loaded; there is simply nothing to suggest.
    expect(cubit.state.cycle.next, isNull);
    expect(cubit.state.date, DateTime(2026, 7, 20));
  });

  test("exposes the cycle's next routine once loaded", () async {
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    final getRoutineCycleUseCase = MockGetRoutineCycleUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(
      getRoutineCycleUseCase.call,
    ).thenAnswer((_) async => Success(RoutineCycle(routines: RoutineFactory.buildCycle(), lastRoutineId: 'routine-a')));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      getRoutineCycleUseCase: getRoutineCycleUseCase,
    );

    await cubit.loadDate(DateTime(2026, 7, 20));

    expect(cubit.state.cycle.next?.id, 'routine-b');
  });

  test('startRoutine reloads the day so the pre-filled sets show up', () async {
    useMockLog();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    final startWorkoutFromRoutineUseCase = MockStartWorkoutFromRoutineUseCase();
    final getRoutineCycleUseCase = MockGetRoutineCycleUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(getRoutineCycleUseCase.call).thenAnswer((_) async => const Success(RoutineCycle(routines: [])));
    when(
      () => startWorkoutFromRoutineUseCase(
        routine: any(named: 'routine'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async => Success(WorkoutFactory.build()));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      startWorkoutFromRoutineUseCase: startWorkoutFromRoutineUseCase,
      getRoutineCycleUseCase: getRoutineCycleUseCase,
    );

    await cubit.startRoutine(RoutineFactory.build());

    verify(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).called(1);
  });
}
