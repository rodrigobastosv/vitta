sealed class ExerciseWorkoutPresentationEvent {}

class ExerciseWorkoutShowLoading implements ExerciseWorkoutPresentationEvent {}

class ExerciseWorkoutHideLoading implements ExerciseWorkoutPresentationEvent {}

class ExerciseWorkoutSetLogged implements ExerciseWorkoutPresentationEvent {}

class ExerciseWorkoutError implements ExerciseWorkoutPresentationEvent {
  const ExerciseWorkoutError({required this.message});

  final String message;
}
