import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_presentation_event.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

ExerciseWorkoutCubit _cubitWithOneSet({required MockLogSetUseCase logSetUseCase}) => CubitsFactories.buildExerciseWorkoutCubit(
  logSetUseCase: logSetUseCase,
  extra: ExerciseWorkoutExtra(
    unitSystem: UnitSystem.metric,
    workoutExercise: WorkoutExerciseFactory.build(
      id: 'we-1',
      sets: [WorkoutSetFactory.build(id: 's1', reps: 8, weightKg: 50)],
    ),
  ),
);

void main() {
  setUpAll(() => registerFallbackValue(const SetInput.strength(reps: 1, weightKg: 0)));

  test('the repeated set is on screen before the write comes back', () async {
    final writing = Completer<Result<VTError, WorkoutSet>>();
    final logSetUseCase = MockLogSetUseCase();
    when(
      () => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input')),
    ).thenAnswer((_) => writing.future);
    final cubit = _cubitWithOneSet(logSetUseCase: logSetUseCase);

    final repeating = cubit.repeatLastSet();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.workoutExercise.sets, hasLength(2));
    expect(cubit.state.workoutExercise.volumeKg, 800);

    writing.complete(Success(WorkoutSetFactory.build(id: 's2', position: 1, reps: 8, weightKg: 50)));
    await repeating;
  });

  test('the settled exercise carries the persisted set, not the placeholder', () async {
    final logSetUseCase = MockLogSetUseCase();
    when(
      () => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input')),
    ).thenAnswer((_) async => Success(WorkoutSetFactory.build(id: 's2', position: 1, reps: 8, weightKg: 50)));
    final cubit = _cubitWithOneSet(logSetUseCase: logSetUseCase);

    await cubit.repeatLastSet();

    expect([for (final set in cubit.state.workoutExercise.sets) set.id], ['s1', 's2']);
    verify(() => logSetUseCase(workoutExerciseId: 'we-1', input: const SetInput.strength(reps: 8, weightKg: 50))).called(1);
  });

  test('a failed repeat puts the sets back exactly as they were', () async {
    final logSetUseCase = MockLogSetUseCase();
    when(
      () => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input')),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final cubit = _cubitWithOneSet(logSetUseCase: logSetUseCase);
    final events = <ExerciseWorkoutPresentationEvent>[];
    cubit.presentation.listen(events.add);
    final setsBeforeRepeat = cubit.state.workoutExercise.sets;

    await cubit.repeatLastSet();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.workoutExercise.sets, setsBeforeRepeat);
    expect(events.whereType<ExerciseWorkoutError>(), hasLength(1));
    expect(events.whereType<ExerciseWorkoutSetLogged>(), isEmpty);
  });

  // The set shows instantly; the rest starts a beat later, once the row exists
  // (issue #275 on top of #228). A rest that vanishes with a failed write would be
  // worse than one that starts late.
  test('the rest is announced only once the write lands, never at the optimistic emit', () async {
    final writing = Completer<Result<VTError, WorkoutSet>>();
    final logSetUseCase = MockLogSetUseCase();
    when(
      () => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input')),
    ).thenAnswer((_) => writing.future);
    final cubit = _cubitWithOneSet(logSetUseCase: logSetUseCase);
    final events = <ExerciseWorkoutPresentationEvent>[];
    cubit.presentation.listen(events.add);

    final repeating = cubit.repeatLastSet();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.workoutExercise.sets, hasLength(2));
    expect(events.whereType<ExerciseWorkoutSetLogged>(), isEmpty);

    writing.complete(Success(WorkoutSetFactory.build(id: 's2', position: 1, reps: 8, weightKg: 50)));
    await repeating;
    await Future<void>.delayed(Duration.zero);

    expect(events.whereType<ExerciseWorkoutSetLogged>(), hasLength(1));
  });

  // Repeating a set and finishing the exercise before the write lands used to
  // start a rest for an exercise that was already done - which then read as the
  // next exercise's own timer (issue #277).
  test('a repeat that lands after the exercise was finished announces no rest', () async {
    final writing = Completer<Result<VTError, WorkoutSet>>();
    final logSetUseCase = MockLogSetUseCase();
    when(() => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input'))).thenAnswer((_) => writing.future);
    final setWorkoutExerciseCompletedUseCase = MockSetWorkoutExerciseCompletedUseCase();
    when(() => setWorkoutExerciseCompletedUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), completed: any(named: 'completed'))).thenAnswer(
      (_) async => Success(
        WorkoutExerciseFactory.build(
          id: 'we-1',
          sets: [WorkoutSetFactory.build(id: 's1', reps: 8, weightKg: 50)],
          completedAt: DateTime(2026, 7, 31),
        ),
      ),
    );
    final cubit = CubitsFactories.buildExerciseWorkoutCubit(
      logSetUseCase: logSetUseCase,
      setWorkoutExerciseCompletedUseCase: setWorkoutExerciseCompletedUseCase,
      extra: ExerciseWorkoutExtra(
        unitSystem: UnitSystem.metric,
        workoutExercise: WorkoutExerciseFactory.build(
          id: 'we-1',
          sets: [WorkoutSetFactory.build(id: 's1', reps: 8, weightKg: 50)],
        ),
      ),
    );
    final events = <ExerciseWorkoutPresentationEvent>[];
    cubit.presentation.listen(events.add);

    final repeating = cubit.repeatLastSet();
    await cubit.setCompleted(completed: true);
    writing.complete(Success(WorkoutSetFactory.build(id: 's2', position: 1, reps: 8, weightKg: 50)));
    await repeating;
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isCompleted, isTrue);
    expect(events.whereType<ExerciseWorkoutSetLogged>(), isEmpty, reason: 'a finished exercise has no next set to rest for');
  });

  test('a cardio effort is never repeated, so a second one cannot be written', () async {
    final logSetUseCase = MockLogSetUseCase();
    final cubit = CubitsFactories.buildExerciseWorkoutCubit(
      logSetUseCase: logSetUseCase,
      extra: ExerciseWorkoutExtra(
        unitSystem: UnitSystem.metric,
        workoutExercise: WorkoutExerciseFactory.build(
          exercise: ExerciseFactory.build(category: ExerciseCategory.cardio),
          sets: [WorkoutSetFactory.cardio()],
        ),
      ),
    );

    await cubit.repeatLastSet();

    expect(cubit.state.workoutExercise.sets, hasLength(1));
    verifyNever(() => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input')));
  });

  test('an exercise with nothing to repeat writes nothing and shows nothing', () async {
    final logSetUseCase = MockLogSetUseCase();
    final cubit = CubitsFactories.buildExerciseWorkoutCubit(
      logSetUseCase: logSetUseCase,
      extra: ExerciseWorkoutExtra(unitSystem: UnitSystem.metric, workoutExercise: WorkoutExerciseFactory.build()),
    );

    await cubit.repeatLastSet();

    expect(cubit.state.workoutExercise.sets, isEmpty);
    verifyNever(() => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input')));
  });
}
