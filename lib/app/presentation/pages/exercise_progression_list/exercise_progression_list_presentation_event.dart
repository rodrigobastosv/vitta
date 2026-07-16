sealed class ExerciseProgressionListPresentationEvent {}

class ExerciseProgressionListShowLoading implements ExerciseProgressionListPresentationEvent {}

class ExerciseProgressionListHideLoading implements ExerciseProgressionListPresentationEvent {}

class ExerciseProgressionListError implements ExerciseProgressionListPresentationEvent {
  const ExerciseProgressionListError({required this.message});

  final String message;
}
