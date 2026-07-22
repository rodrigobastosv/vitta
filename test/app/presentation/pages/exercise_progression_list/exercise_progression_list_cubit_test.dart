import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_state.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  blocTest<ExerciseProgressionListCubit, ExerciseProgressionListState>(
    'load emits the logged exercises',
    build: () {
      final getLoggedExercisesUseCase = MockGetLoggedExercisesUseCase();
      when(getLoggedExercisesUseCase.call).thenAnswer((_) async => Success([ExerciseFactory.build(id: 'a'), ExerciseFactory.build(id: 'b')]));
      return ExerciseProgressionListCubit(getLoggedExercisesUseCase: getLoggedExercisesUseCase);
    },
    act: (cubit) => cubit.load(),
    expect: () => [isA<ExerciseProgressionListState>().having((state) => state.exercises, 'exercises', hasLength(2))],
  );

  blocPresentationTest<ExerciseProgressionListCubit, ExerciseProgressionListState, ExerciseProgressionListPresentationEvent>(
    'load surfaces a failure as an error event',
    build: () {
      final getLoggedExercisesUseCase = MockGetLoggedExercisesUseCase();
      when(getLoggedExercisesUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return ExerciseProgressionListCubit(getLoggedExercisesUseCase: getLoggedExercisesUseCase);
    },
    act: (cubit) => cubit.load(),
    expectPresentation: () => [isA<ExerciseProgressionListError>().having((event) => event.message, 'message', 'offline')],
  );
}
