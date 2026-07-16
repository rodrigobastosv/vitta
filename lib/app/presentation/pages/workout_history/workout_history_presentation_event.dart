sealed class WorkoutHistoryPresentationEvent {}

class WorkoutHistoryShowLoading implements WorkoutHistoryPresentationEvent {}

class WorkoutHistoryHideLoading implements WorkoutHistoryPresentationEvent {}

class WorkoutHistoryError implements WorkoutHistoryPresentationEvent {
  const WorkoutHistoryError({required this.message});

  final String message;
}
