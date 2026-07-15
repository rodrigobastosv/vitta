class CreateWorkoutExerciseRequest {
  CreateWorkoutExerciseRequest({required this.workoutId, required this.exerciseId, required this.position});

  final String workoutId;
  final String exerciseId;
  final int position;

  Map<String, dynamic> toJson() => {'workout_id': workoutId, 'exercise_id': exerciseId, 'position': position};
}
