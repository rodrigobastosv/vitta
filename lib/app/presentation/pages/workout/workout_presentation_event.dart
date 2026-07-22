sealed class WorkoutPresentationEvent {}

class WorkoutShowLoading implements WorkoutPresentationEvent {}

class WorkoutHideLoading implements WorkoutPresentationEvent {}

class WorkoutShowIntro implements WorkoutPresentationEvent {}

// The last exercise of the day was just checked off (issue #168). An event rather
// than a state field because it is a moment, not a condition: opening a day that
// was already finished must not replay the summary, which is the whole reason the
// cubit tests the transition rather than isFinished.
class WorkoutSessionFinished implements WorkoutPresentationEvent {}

class WorkoutError implements WorkoutPresentationEvent {
  const WorkoutError({required this.message, required this.date});

  final String message;
  final DateTime date;
}
