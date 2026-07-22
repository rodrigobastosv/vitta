import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_state.dart';

import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

// The exercise workspace and the day list are two screens performing the same
// domain action, and only the day list used to report it - so every set logged
// from the workspace (which is where the app sends the user to log one) was
// missing from the funnel. These pin the parity: same event name, same payload.
void main() {
  setUpAll(() {
    registerFallbackValue(const SetInput.strength(reps: 1, weightKg: 0));
    registerFallbackValue(<String, Object?>{});
  });

  blocTest<ExerciseWorkoutCubit, ExerciseWorkoutState>(
    'logging a set reports workout_set_logged with the set it wrote',
    build: () {
      final loggingService = useMockLog();
      final logSetUseCase = MockLogSetUseCase();
      when(() => logSetUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), input: any(named: 'input'))).thenAnswer(
        (_) async => Success(WorkoutSetFactory.build()),
      );
      addTearDown(
        () => verify(() => loggingService.logAction('workout_set_logged', data: {'reps': 10, 'weight_kg': 40.0})).called(1),
      );
      return ExerciseWorkoutCubit(
        extra: ExerciseWorkoutExtra(workoutExercise: WorkoutExerciseFactory.build(), unitSystem: .metric),
        logSetUseCase: logSetUseCase,
        updateSetUseCase: MockUpdateSetUseCase(),
        deleteSetUseCase: MockDeleteSetUseCase(),
        setWorkoutExerciseCompletedUseCase: MockSetWorkoutExerciseCompletedUseCase(),
      );
    },
    act: (cubit) => cubit.logSet(input: const SetInput.strength(reps: 10, weightKg: 40)),
  );

  blocTest<ExerciseWorkoutCubit, ExerciseWorkoutState>(
    'deleting a set reports workout_set_deleted',
    build: () {
      final loggingService = useMockLog();
      final deleteSetUseCase = MockDeleteSetUseCase();
      when(() => deleteSetUseCase(setId: any(named: 'setId'))).thenAnswer((_) async => const Success(null));
      addTearDown(() => verify(() => loggingService.logAction('workout_set_deleted')).called(1));
      return ExerciseWorkoutCubit(
        extra: ExerciseWorkoutExtra(workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]), unitSystem: .metric),
        logSetUseCase: MockLogSetUseCase(),
        updateSetUseCase: MockUpdateSetUseCase(),
        deleteSetUseCase: deleteSetUseCase,
        setWorkoutExerciseCompletedUseCase: MockSetWorkoutExerciseCompletedUseCase(),
      );
    },
    act: (cubit) => cubit.deleteSet(setId: 'set-1'),
  );

  blocTest<ExerciseWorkoutCubit, ExerciseWorkoutState>(
    'finishing an exercise reports workout_exercise_completed',
    build: () {
      final loggingService = useMockLog();
      final completedUseCase = MockSetWorkoutExerciseCompletedUseCase();
      when(
        () => completedUseCase(workoutExerciseId: any(named: 'workoutExerciseId'), completed: any(named: 'completed')),
      ).thenAnswer((_) async => Success(WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()], completedAt: DateTime(2024))));
      addTearDown(() => verify(() => loggingService.logAction('workout_exercise_completed')).called(1));
      return ExerciseWorkoutCubit(
        extra: ExerciseWorkoutExtra(workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]), unitSystem: .metric),
        logSetUseCase: MockLogSetUseCase(),
        updateSetUseCase: MockUpdateSetUseCase(),
        deleteSetUseCase: MockDeleteSetUseCase(),
        setWorkoutExerciseCompletedUseCase: completedUseCase,
      );
    },
    act: (cubit) => cubit.setCompleted(completed: true),
  );
}
