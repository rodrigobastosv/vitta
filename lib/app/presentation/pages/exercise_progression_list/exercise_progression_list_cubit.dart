import 'package:vitta/app/domain/workout/use_cases/get_logged_exercises_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_state.dart';

class ExerciseProgressionListCubit extends PresentationCubit<ExerciseProgressionListState, ExerciseProgressionListPresentationEvent> {
  ExerciseProgressionListCubit({required this._getLoggedExercisesUseCase}) : super(const ExerciseProgressionListState(isLoaded: false));

  final GetLoggedExercisesUseCase _getLoggedExercisesUseCase;

  @override
  void onInit() => load();

  Future<void> load() async {
    final exercisesResult = await withLoadingOverlay(
      _getLoggedExercisesUseCase.call,
      showOverlay: state.isLoaded,
      showLoadingEvent: ExerciseProgressionListShowLoading(),
      hideLoadingEvent: ExerciseProgressionListHideLoading(),
    );
    exercisesResult.when(
      (error) => emitPresentation(ExerciseProgressionListError(message: error.message)),
      (exercises) => emit(state.copyWith(isLoaded: true, exercises: exercises)),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }
}
