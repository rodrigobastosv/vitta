import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/use_cases/start_workout_from_routine_use_case.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/routine_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  test('creates the workout against the routine so it advances the cycle', () async {
    final workoutRepository = MockWorkoutRepository();
    final routine = RoutineFactory.build(id: 'routine-b', exercises: [ExerciseFactory.build()]);
    when(() => workoutRepository.getLastSetsByExercise(exerciseIds: any(named: 'exerciseIds'))).thenAnswer((_) async => const Success({}));
    when(
      () => workoutRepository.createWorkout(
        performedDate: any(named: 'performedDate'),
        notes: any(named: 'notes'),
        routineId: any(named: 'routineId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutFactory.build()));
    when(
      () => workoutRepository.addWorkoutExercise(
        workoutId: any(named: 'workoutId'),
        exerciseId: any(named: 'exerciseId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build(id: 'we-1')));
    when(() => workoutRepository.logSetsBulk(setsByWorkoutExercise: any(named: 'setsByWorkoutExercise'))).thenAnswer((_) async => const Success(null));

    await StartWorkoutFromRoutineUseCase(workoutRepository: workoutRepository)(routine: routine, date: DateTime(2026, 7, 20));

    verify(() => workoutRepository.createWorkout(performedDate: DateTime(2026, 7, 20), routineId: 'routine-b')).called(1);
  });

  test('pre-fills each exercise with the sets from the last time it was trained', () async {
    final workoutRepository = MockWorkoutRepository();
    final lastSets = [WorkoutSetFactory.build(id: 'old-1', reps: 8, weightKg: 60)];
    final routine = RoutineFactory.build(exercises: [ExerciseFactory.build()]);
    when(() => workoutRepository.getLastSetsByExercise(exerciseIds: any(named: 'exerciseIds'))).thenAnswer((_) async => Success({'exercise-1': lastSets}));
    when(
      () => workoutRepository.createWorkout(
        performedDate: any(named: 'performedDate'),
        notes: any(named: 'notes'),
        routineId: any(named: 'routineId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutFactory.build()));
    when(
      () => workoutRepository.addWorkoutExercise(
        workoutId: any(named: 'workoutId'),
        exerciseId: any(named: 'exerciseId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build(id: 'we-1')));
    when(() => workoutRepository.logSetsBulk(setsByWorkoutExercise: any(named: 'setsByWorkoutExercise'))).thenAnswer((_) async => const Success(null));

    await StartWorkoutFromRoutineUseCase(workoutRepository: workoutRepository)(routine: routine, date: DateTime(2026, 7, 20));

    final captured =
        verify(() => workoutRepository.logSetsBulk(setsByWorkoutExercise: captureAny(named: 'setsByWorkoutExercise'))).captured.single
            as Map<String, List<WorkoutSet>>;
    expect(captured['we-1']?.single.weightKg, 60);
  });

  test('an exercise never trained before starts with no sets rather than a zeroed one', () async {
    final workoutRepository = MockWorkoutRepository();
    final routine = RoutineFactory.build(exercises: [ExerciseFactory.build(id: 'brand-new')]);
    when(() => workoutRepository.getLastSetsByExercise(exerciseIds: any(named: 'exerciseIds'))).thenAnswer((_) async => const Success({}));
    when(
      () => workoutRepository.createWorkout(
        performedDate: any(named: 'performedDate'),
        notes: any(named: 'notes'),
        routineId: any(named: 'routineId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutFactory.build()));
    when(
      () => workoutRepository.addWorkoutExercise(
        workoutId: any(named: 'workoutId'),
        exerciseId: any(named: 'exerciseId'),
      ),
    ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build(id: 'we-1')));
    when(() => workoutRepository.logSetsBulk(setsByWorkoutExercise: any(named: 'setsByWorkoutExercise'))).thenAnswer((_) async => const Success(null));

    await StartWorkoutFromRoutineUseCase(workoutRepository: workoutRepository)(routine: routine, date: DateTime(2026, 7, 20));

    final captured =
        verify(() => workoutRepository.logSetsBulk(setsByWorkoutExercise: captureAny(named: 'setsByWorkoutExercise'))).captured.single
            as Map<String, List<WorkoutSet>>;
    expect(captured, isEmpty);
  });

  test('does not create a workout when the previous-sets lookup fails', () async {
    final workoutRepository = MockWorkoutRepository();
    when(
      () => workoutRepository.getLastSetsByExercise(exerciseIds: any(named: 'exerciseIds')),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));

    final startedResult = await StartWorkoutFromRoutineUseCase(workoutRepository: workoutRepository)(
      routine: RoutineFactory.build(),
      date: DateTime(2026, 7, 20),
    );

    expect(startedResult, isA<Failure<VTError, dynamic>>());
    verifyNever(
      () => workoutRepository.createWorkout(
        performedDate: any(named: 'performedDate'),
        notes: any(named: 'notes'),
        routineId: any(named: 'routineId'),
      ),
    );
  });
}
