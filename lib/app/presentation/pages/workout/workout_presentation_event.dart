sealed class WorkoutPresentationEvent {}

class WorkoutShowLoading implements WorkoutPresentationEvent {}

class WorkoutHideLoading implements WorkoutPresentationEvent {}

class WorkoutShowIntro implements WorkoutPresentationEvent {}

class WorkoutError implements WorkoutPresentationEvent {
  const WorkoutError({required this.message, required this.date});

  final String message;
  final DateTime date;
}
