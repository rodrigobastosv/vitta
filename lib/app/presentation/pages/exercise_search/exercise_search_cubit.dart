import 'dart:async';

import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/domain/workout/use_cases/search_exercises_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_state.dart';

class ExerciseSearchCubit extends PresentationCubit<ExerciseSearchState, ExerciseSearchPresentationEvent> {
  ExerciseSearchCubit({required this._searchExercisesUseCase}) : super(const ExerciseSearchState());

  final SearchExercisesUseCase _searchExercisesUseCase;

  static const Duration _debounce = Duration(milliseconds: 350);
  static const int _minQueryLength = 2;

  Timer? _debounceTimer;

  @override
  void onInit() => search('');

  // Search as the user types, debounced - the same instant-feeling flow as food
  // search. A 1-character query just parks the text; empty (clearing the field) and
  // 2+ both re-search, since an empty query here means "show every exercise".
  void queryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.isNotEmpty && query.trim().length < _minQueryLength) {
      emit(state.copyWith(query: query));
      return;
    }
    _debounceTimer = Timer(_debounce, () => search(query));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

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
