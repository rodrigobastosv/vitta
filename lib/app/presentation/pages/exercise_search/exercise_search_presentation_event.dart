sealed class ExerciseSearchPresentationEvent {}

class ExerciseSearchShowLoading implements ExerciseSearchPresentationEvent {}

class ExerciseSearchHideLoading implements ExerciseSearchPresentationEvent {}

class ExerciseSearchError implements ExerciseSearchPresentationEvent {
  const ExerciseSearchError({required this.message});

  final String message;
}
