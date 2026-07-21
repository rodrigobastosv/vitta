import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/domain/workout/use_cases/search_exercises_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_state.dart';

class ExerciseSearchCubit extends PresentationCubit<ExerciseSearchState, ExerciseSearchPresentationEvent> {
  ExerciseSearchCubit({required this._searchExercisesUseCase}) : super(const ExerciseSearchState());

  final SearchExercisesUseCase _searchExercisesUseCase;

  @override
  void onInit() => search('');

  Future<void> search(String query) async {
    emit(state.copyWith(query: query));
    await _runSearch();
  }

  Future<void> changeMuscleGroup(MuscleGroup? muscleGroup) async {
    emit(state.copyWith(muscleGroup: muscleGroup, clearMuscleGroup: muscleGroup == null));
    await _runSearch();
  }

  Future<void> _runSearch() async {
    emitPresentation(ExerciseSearchShowLoading());
    final exercisesResult = await _searchExercisesUseCase(query: state.query, muscleGroup: state.muscleGroup);
    emitPresentation(ExerciseSearchHideLoading());
    exercisesResult.when((error) => emitPresentation(ExerciseSearchError(message: error.message)), (value) => emit(state.copyWith(results: value)));
  }
}
