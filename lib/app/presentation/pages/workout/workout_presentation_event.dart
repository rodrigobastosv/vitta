import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

sealed class WorkoutPresentationEvent {}

class WorkoutShowLoading implements WorkoutPresentationEvent {}

class WorkoutHideLoading implements WorkoutPresentationEvent {}

class WorkoutShowIntro implements WorkoutPresentationEvent {}

// The last exercise of the day was just checked off (issue #168). An event rather
// than a state field because it is a moment, not a condition: opening a day that
// was already finished must not replay the summary, which is the whole reason the
// cubit tests the transition rather than isFinished.
class WorkoutSessionFinished implements WorkoutPresentationEvent {}

// A set was actually written (issue #228). The rest timer hangs off this rather
// than off the repeat tap returning, because repeatLastSet no-ops on an exercise
// with nothing to repeat and reports a failed write the same way it reports
// success - so starting a rest at the call site timed a set that never happened.
// It carries the exercise rather than a label: the cubit has no business knowing
// how a name is localized.
class WorkoutSetRepeated implements WorkoutPresentationEvent {
  const WorkoutSetRepeated({required this.workoutExercise});

  final WorkoutExercise workoutExercise;
}

class WorkoutError implements WorkoutPresentationEvent {
  const WorkoutError({required this.message, required this.date});

  final String message;
  final DateTime date;
}
