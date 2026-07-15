import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/workout/workout_cubit.dart';
import 'package:vitta/app/presentation/pages/workout/workout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
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
      return CubitsFactories.buildWorkoutCubit(getWorkoutsForDateUseCase: getWorkoutsForDateUseCase);
    },
    act: (cubit) => cubit.loadDate(DateTime(2026, 7, 15)),
    expect: () => [isA<WorkoutState>().having((state) => state.volumeKg, 'volumeKg', 400)],
  );

  blocPresentationTest<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
    'shows then hides loading while the day loads',
    build: () {
      final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
      when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildWorkoutCubit(getWorkoutsForDateUseCase: getWorkoutsForDateUseCase);
    },
    act: (cubit) => cubit.loadDate(DateTime(2026, 7, 15)),
    expectPresentation: () => [isA<WorkoutShowLoading>(), isA<WorkoutHideLoading>()],
  );

  blocPresentationTest<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
    'reports the failed date on the error event, not whatever date the state holds later',
    build: () {
      final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
      when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildWorkoutCubit(getWorkoutsForDateUseCase: getWorkoutsForDateUseCase);
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
    final cubit = CubitsFactories.buildWorkoutCubit(getWorkoutsForDateUseCase: getWorkoutsForDateUseCase, logSetUseCase: logSetUseCase);

    final loggedResult = await cubit.logSet(workoutExerciseId: 'we-1', reps: 10, weightKg: 40);

    expect(loggedResult, isA<Failure<VTError, void>>());
  });

  test('unitSystem reads settings directly rather than through AppCubit', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings(unitSystem: UnitSystem.imperial));
    final cubit = CubitsFactories.buildWorkoutCubit(getAppSettingsUseCase: getAppSettingsUseCase);

    expect(cubit.unitSystem, UnitSystem.imperial);
  });
}
