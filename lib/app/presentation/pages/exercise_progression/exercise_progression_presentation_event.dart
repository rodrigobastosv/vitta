sealed class ExerciseProgressionPresentationEvent {}

class ExerciseProgressionShowLoading implements ExerciseProgressionPresentationEvent {}

class ExerciseProgressionHideLoading implements ExerciseProgressionPresentationEvent {}

class ExerciseProgressionError implements ExerciseProgressionPresentationEvent {
  const ExerciseProgressionError({required this.message});

  final String message;
}
