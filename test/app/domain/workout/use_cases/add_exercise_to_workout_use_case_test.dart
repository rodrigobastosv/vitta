import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/use_cases/add_exercise_to_workout_use_case.dart';

import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  test('pre-fills the added exercise with the sets from the last time it was trained', () async {
    final workoutRepository = MockWorkoutRepository();
    final lastSets = [WorkoutSetFactory.build(id: 'old-1', reps: 8, weightKg: 60)];
    when(
      () => workoutRepository.getLastSetsByExercise(
        exerciseIds: any(named: 'exerciseIds'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => Success({'exercise-1': lastSets}));
    when(
      () => workoutRepository.addWorkoutExercise(
        workoutId: any(named: 'workoutId'),
        exerciseId: any(named: 'exerciseId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build(id: 'we-9')));
    when(
      () => workoutRepository.logSetsBulk(setsByWorkoutExercise: any(named: 'setsByWorkoutExercise')),
    ).thenAnswer((_) async => const Success(null));

    await AddExerciseToWorkoutUseCase(workoutRepository: workoutRepository)(
      date: DateTime(2026, 7, 20),
      exerciseId: 'exercise-1',
      workoutId: 'workout-1',
    );

    final captured =
        verify(() => workoutRepository.logSetsBulk(setsByWorkoutExercise: captureAny(named: 'setsByWorkoutExercise'))).captured.single
            as Map<String, List<WorkoutSet>>;
    expect(captured['we-9']?.single.weightKg, 60);
  });

  test('adds no sets when the exercise was never trained before', () async {
    final workoutRepository = MockWorkoutRepository();
    when(
      () => workoutRepository.getLastSetsByExercise(
        exerciseIds: any(named: 'exerciseIds'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => const Success({}));
    when(
      () => workoutRepository.addWorkoutExercise(
        workoutId: any(named: 'workoutId'),
        exerciseId: any(named: 'exerciseId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build(id: 'we-9')));

    await AddExerciseToWorkoutUseCase(workoutRepository: workoutRepository)(
      date: DateTime(2026, 7, 20),
      exerciseId: 'brand-new',
      workoutId: 'workout-1',
    );

    verifyNever(() => workoutRepository.logSetsBulk(setsByWorkoutExercise: any(named: 'setsByWorkoutExercise')));
  });

  test("creates the day's workout when there is none yet, then attaches the exercise", () async {
    final workoutRepository = MockWorkoutRepository();
    when(
      () => workoutRepository.getLastSetsByExercise(
        exerciseIds: any(named: 'exerciseIds'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => const Success({}));
    when(
      () => workoutRepository.createWorkout(
        performedDate: any(named: 'performedDate'),
        notes: any(named: 'notes'),
        routineId: any(named: 'routineId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutFactory.build(id: 'workout-new')));
    when(
      () => workoutRepository.addWorkoutExercise(
        workoutId: any(named: 'workoutId'),
        exerciseId: any(named: 'exerciseId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build(id: 'we-9')));

    await AddExerciseToWorkoutUseCase(workoutRepository: workoutRepository)(date: DateTime(2026, 7, 20), exerciseId: 'exercise-1');

    verify(() => workoutRepository.createWorkout(performedDate: DateTime(2026, 7, 20))).called(1);
    verify(() => workoutRepository.addWorkoutExercise(workoutId: 'workout-new', exerciseId: 'exercise-1')).called(1);
  });

  test('does not create a workout when the previous-sets lookup fails', () async {
    final workoutRepository = MockWorkoutRepository();
    when(
      () => workoutRepository.getLastSetsByExercise(
        exerciseIds: any(named: 'exerciseIds'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));

    final addedResult = await AddExerciseToWorkoutUseCase(workoutRepository: workoutRepository)(
      date: DateTime(2026, 7, 20),
      exerciseId: 'exercise-1',
    );

    expect(addedResult, isA<Failure<VTError, dynamic>>());
    verifyNever(
      () => workoutRepository.createWorkout(
        performedDate: any(named: 'performedDate'),
        notes: any(named: 'notes'),
        routineId: any(named: 'routineId'),
      ),
    );
    verifyNever(
      () => workoutRepository.addWorkoutExercise(
        workoutId: any(named: 'workoutId'),
        exerciseId: any(named: 'exerciseId'),
      ),
    );
  });
}
