sealed class WorkoutPresentationEvent {}

class WorkoutShowLoading implements WorkoutPresentationEvent {}

class WorkoutHideLoading implements WorkoutPresentationEvent {}

class WorkoutShowIntro implements WorkoutPresentationEvent {}

/// The day's last exercise was just checked off. Fired **on the edge**, never on
/// the state: a workout that is already finished must not push its summary again
/// every time the page reloads, which is the same rule VTCelebration follows.
class WorkoutFinished implements WorkoutPresentationEvent {}

class WorkoutError implements WorkoutPresentationEvent {
  const WorkoutError({required this.message, required this.date});

  final String message;
  final DateTime date;
}
