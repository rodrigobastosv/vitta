import 'package:vitta/app/domain/workout/use_cases/get_logged_exercises_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_state.dart';

class ExerciseProgressionListCubit extends PresentationCubit<ExerciseProgressionListState, ExerciseProgressionListPresentationEvent> {
  ExerciseProgressionListCubit({required this._getLoggedExercisesUseCase}) : super(const ExerciseProgressionListState());

  final GetLoggedExercisesUseCase _getLoggedExercisesUseCase;

  @override
  void onInit() => load();

  Future<void> load() async {
    emitPresentation(ExerciseProgressionListShowLoading());
    final exercisesResult = await _getLoggedExercisesUseCase();
    exercisesResult.when(
      (error) => emitPresentation(ExerciseProgressionListError(message: error.message)),
      (exercises) => emit(state.copyWith(exercises: exercises)),
    );
    emitPresentation(ExerciseProgressionListHideLoading());
  }
}
