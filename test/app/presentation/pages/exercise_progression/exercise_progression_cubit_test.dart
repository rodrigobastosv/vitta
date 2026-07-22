import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression_point.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_state.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

ExerciseProgressionCubit _buildCubit(MockGetExerciseProgressionUseCase getExerciseProgressionUseCase) => ExerciseProgressionCubit(
  getExerciseProgressionUseCase: getExerciseProgressionUseCase,
  getAppSettingsUseCase: MockGetAppSettingsUseCase(),
  exercise: ExerciseFactory.build(),
);

void main() {
  blocTest<ExerciseProgressionCubit, ExerciseProgressionState>(
    'load emits the fetched progression',
    build: () {
      final getExerciseProgressionUseCase = MockGetExerciseProgressionUseCase();
      final progression = ExerciseProgression(
        points: [
          ExerciseProgressionPoint(date: DateTime(2026, 7), sets: [WorkoutSetFactory.build()]),
        ],
      );
      when(() => getExerciseProgressionUseCase(exerciseId: 'exercise-1')).thenAnswer((_) async => Success(progression));
      return _buildCubit(getExerciseProgressionUseCase);
    },
    act: (cubit) => cubit.load(),
    expect: () => [isA<ExerciseProgressionState>().having((state) => state.progression.hasData, 'hasData', isTrue)],
  );

  blocPresentationTest<ExerciseProgressionCubit, ExerciseProgressionState, ExerciseProgressionPresentationEvent>(
    'the first load shows no overlay - the skeleton covers it',
    build: () {
      final getExerciseProgressionUseCase = MockGetExerciseProgressionUseCase();
      when(() => getExerciseProgressionUseCase(exerciseId: 'exercise-1')).thenAnswer((_) async => const Success(ExerciseProgression(points: [])));
      return _buildCubit(getExerciseProgressionUseCase);
    },
    act: (cubit) => cubit.load(),
    expectPresentation: () => <ExerciseProgressionPresentationEvent>[],
  );

  blocPresentationTest<ExerciseProgressionCubit, ExerciseProgressionState, ExerciseProgressionPresentationEvent>(
    'load surfaces a failure as an error event',
    build: () {
      final getExerciseProgressionUseCase = MockGetExerciseProgressionUseCase();
      when(() => getExerciseProgressionUseCase(exerciseId: 'exercise-1')).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return _buildCubit(getExerciseProgressionUseCase);
    },
    act: (cubit) => cubit.load(),
    expectPresentation: () => [isA<ExerciseProgressionError>().having((event) => event.message, 'message', 'offline')],
  );
}
