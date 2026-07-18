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
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/routine_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

MockGetRoutineCycleUseCase _emptyCycleUseCase() {
  final useCase = MockGetRoutineCycleUseCase();
  when(useCase.call).thenAnswer((_) async => const Success(RoutineCycle(routines: [])));
  return useCase;
}

MockGetLastSetsByExerciseUseCase _emptyLastSetsUseCase() {
  final useCase = MockGetLastSetsByExerciseUseCase();
  when(
    () => useCase(
      exerciseIds: any(named: 'exerciseIds'),
      before: any(named: 'before'),
    ),
  ).thenAnswer((_) async => const Success({}));
  return useCase;
}

MockGetLatestBodyWeightUseCase _noBodyWeightUseCase() {
  final useCase = MockGetLatestBodyWeightUseCase();
  when(useCase.call).thenAnswer((_) async => const Success(null));
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
        getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
        getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
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
        getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
        getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
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
        getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
        getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
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
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    await cubit.addExercise(ExerciseFactory.build(id: 'exercise-9'));

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
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    final loggedResult = await cubit.logSet(workoutExerciseId: 'we-1', reps: 10, weightKg: 40);

    expect(loggedResult, isA<Failure<VTError, void>>());
  });

  test('loadDate stores the latest body weight for the bodyweight prefill', () async {
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
    when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => Success(BodyWeightLogFactory.build(weightKg: 82)));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: getLatestBodyWeightUseCase,
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    await cubit.loadDate(DateTime(2026, 7, 15));

    expect(cubit.state.latestBodyWeightKg, 82);
  });

  test('a failed latest-body-weight load leaves the prefill unset without breaking the day', () async {
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
    when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: getLatestBodyWeightUseCase,
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    await cubit.loadDate(DateTime(2026, 7, 15));

    expect(cubit.state.latestBodyWeightKg, isNull);
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
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
    );

    await cubit.loadDate(DateTime(2026, 7, 20));

    expect(cubit.state.cycle.next, isNull);
    expect(cubit.state.date, DateTime(2026, 7, 20));
  });

  test("loads each exercise's previous session for the last-time hint, scoped before the shown day", () async {
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    final getLastSetsByExerciseUseCase = MockGetLastSetsByExerciseUseCase();
    final lastSets = [WorkoutSetFactory.build(id: 'old-1', reps: 8, weightKg: 60)];
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer(
      (_) async => Success([
        WorkoutFactory.build(
          exercises: [
            WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
          ],
        ),
      ]),
    );
    when(
      () => getLastSetsByExerciseUseCase(
        exerciseIds: any(named: 'exerciseIds'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => Success({'exercise-1': lastSets}));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: getLastSetsByExerciseUseCase,
    );

    await cubit.loadDate(DateTime(2026, 7, 20));

    expect(cubit.state.lastSetsByExercise['exercise-1'], lastSets);
    verify(() => getLastSetsByExerciseUseCase(exerciseIds: ['exercise-1'], before: DateTime(2026, 7, 20))).called(1);
  });

  test('a failed last-time lookup leaves the hint empty without breaking the day', () async {
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    final getLastSetsByExerciseUseCase = MockGetLastSetsByExerciseUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer(
      (_) async => Success([
        WorkoutFactory.build(exercises: [WorkoutExerciseFactory.build()]),
      ]),
    );
    when(
      () => getLastSetsByExerciseUseCase(
        exerciseIds: any(named: 'exerciseIds'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: getLastSetsByExerciseUseCase,
    );

    await cubit.loadDate(DateTime(2026, 7, 20));

    expect(cubit.state.lastSetsByExercise, isEmpty);
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
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
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
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
    );

    await cubit.startRoutine(RoutineFactory.build());

    verify(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).called(1);
  });

  test('refuses to start a routine on a past day - a workout happens on its own day', () async {
    useMockLog();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    final startWorkoutFromRoutineUseCase = MockStartWorkoutFromRoutineUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      startWorkoutFromRoutineUseCase: startWorkoutFromRoutineUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );
    await cubit.goToDate(DateTime(2020));

    await cubit.startRoutine(RoutineFactory.build());

    verifyNever(
      () => startWorkoutFromRoutineUseCase(
        routine: any(named: 'routine'),
        date: any(named: 'date'),
      ),
    );
  });

  test('starts a routine on today', () async {
    useMockLog();
    final now = DateTime.now();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    final startWorkoutFromRoutineUseCase = MockStartWorkoutFromRoutineUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(
      () => startWorkoutFromRoutineUseCase(
        routine: any(named: 'routine'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async => Success(WorkoutFactory.build()));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      startWorkoutFromRoutineUseCase: startWorkoutFromRoutineUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );
    await cubit.goToDate(DateTime(now.year, now.month, now.day));

    await cubit.startRoutine(RoutineFactory.build());

    verify(
      () => startWorkoutFromRoutineUseCase(
        routine: any(named: 'routine'),
        date: any(named: 'date'),
      ),
    ).called(1);
  });

  test('repeatLastSet logs another set identical to the last one', () async {
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
    ).thenAnswer((_) async => Success(WorkoutSetFactory.build()));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      logSetUseCase: logSetUseCase,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    await cubit.repeatLastSet(
      workoutExercise: WorkoutExerciseFactory.build(
        id: 'we-1',
        sets: [
          WorkoutSetFactory.build(id: 's1', reps: 12, weightKg: 30),
          WorkoutSetFactory.build(id: 's2', reps: 8, weightKg: 50),
        ],
      ),
    );

    verify(() => logSetUseCase(workoutExerciseId: 'we-1', reps: 8, weightKg: 50)).called(1);
  });

  test('repeatLastSet does nothing when there is no set to repeat', () async {
    useMockLog();
    final logSetUseCase = MockLogSetUseCase();
    final cubit = CubitsFactories.buildWorkoutCubit(logSetUseCase: logSetUseCase);

    await cubit.repeatLastSet(workoutExercise: WorkoutExerciseFactory.build());

    verifyNever(
      () => logSetUseCase(
        workoutExerciseId: any(named: 'workoutExerciseId'),
        reps: any(named: 'reps'),
        weightKg: any(named: 'weightKg'),
      ),
    );
  });

  test('reopening an exercise clears completion rather than stamping a new time', () async {
    useMockLog();
    final setCompleted = MockSetWorkoutExerciseCompletedUseCase();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(
      () => setCompleted(
        workoutExerciseId: any(named: 'workoutExerciseId'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build()));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      setWorkoutExerciseCompletedUseCase: setCompleted,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    await cubit.setExerciseCompleted(
      workoutExercise: WorkoutExerciseFactory.build(id: 'we-1', completedAt: DateTime(2026, 7, 20)),
      completed: false,
    );

    verify(() => setCompleted(workoutExerciseId: 'we-1', completed: false)).called(1);
  });

  test('marking an exercise done reloads the day so the finished state shows', () async {
    useMockLog();
    final setCompleted = MockSetWorkoutExerciseCompletedUseCase();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(
      () => setCompleted(
        workoutExerciseId: any(named: 'workoutExerciseId'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build()));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      setWorkoutExerciseCompletedUseCase: setCompleted,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    await cubit.setExerciseCompleted(
      workoutExercise: WorkoutExerciseFactory.build(id: 'we-1', sets: [WorkoutSetFactory.build()]),
      completed: true,
    );

    verify(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).called(1);
  });

  test('refuses to finish an exercise with no sets - you cannot complete what you did not do', () async {
    useMockLog();
    final setCompleted = MockSetWorkoutExerciseCompletedUseCase();
    final cubit = CubitsFactories.buildWorkoutCubit(setWorkoutExerciseCompletedUseCase: setCompleted);

    await cubit.setExerciseCompleted(workoutExercise: WorkoutExerciseFactory.build(), completed: true);

    verifyNever(
      () => setCompleted(
        workoutExerciseId: any(named: 'workoutExerciseId'),
        completed: any(named: 'completed'),
      ),
    );
  });

  test('reopening is always allowed, even with no sets', () async {
    useMockLog();
    final setCompleted = MockSetWorkoutExerciseCompletedUseCase();
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    when(
      () => setCompleted(
        workoutExerciseId: any(named: 'workoutExerciseId'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build()));
    final cubit = CubitsFactories.buildWorkoutCubit(
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      setWorkoutExerciseCompletedUseCase: setCompleted,
      getRoutineCycleUseCase: _emptyCycleUseCase(),
      getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
      getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
    );

    await cubit.setExerciseCompleted(workoutExercise: WorkoutExerciseFactory.build(id: 'we-1'), completed: false);

    verify(() => setCompleted(workoutExerciseId: 'we-1', completed: false)).called(1);
  });

  blocPresentationTest<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
    'onInit asks to show the intro when it has not been seen yet',
    build: () {
      useMockLog();
      final hasSeenIntro = MockHasSeenWorkoutIntroUseCase();
      when(hasSeenIntro.call).thenReturn(false);
      final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
      when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildWorkoutCubit(
        hasSeenWorkoutIntroUseCase: hasSeenIntro,
        getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
        getRoutineCycleUseCase: _emptyCycleUseCase(),
        getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
        getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
      );
    },
    act: (cubit) => cubit.onInit(),
    expectPresentation: () => [isA<WorkoutShowIntro>(), isA<WorkoutShowLoading>(), isA<WorkoutHideLoading>()],
  );

  blocPresentationTest<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
    'onInit does not show the intro once it has been seen',
    build: () {
      useMockLog();
      final hasSeenIntro = MockHasSeenWorkoutIntroUseCase();
      when(hasSeenIntro.call).thenReturn(true);
      final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
      when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildWorkoutCubit(
        hasSeenWorkoutIntroUseCase: hasSeenIntro,
        getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
        getRoutineCycleUseCase: _emptyCycleUseCase(),
        getLatestBodyWeightUseCase: _noBodyWeightUseCase(),
        getLastSetsByExerciseUseCase: _emptyLastSetsUseCase(),
      );
    },
    act: (cubit) => cubit.onInit(),
    expectPresentation: () => [isA<WorkoutShowLoading>(), isA<WorkoutHideLoading>()],
  );

  test('markIntroSeen records that the intro was seen', () async {
    final markIntroSeen = MockMarkWorkoutIntroSeenUseCase();
    when(markIntroSeen.call).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildWorkoutCubit(markWorkoutIntroSeenUseCase: markIntroSeen);

    await cubit.markIntroSeen();

    verify(markIntroSeen.call).called(1);
  });
}
