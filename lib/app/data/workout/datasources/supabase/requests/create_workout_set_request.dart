class CreateWorkoutSetRequest {
  CreateWorkoutSetRequest({required this.workoutExerciseId, required this.position, required this.reps, required this.weightKg});

  final String workoutExerciseId;
  final int position;
  final int reps;
  final double weightKg;

  Map<String, dynamic> toJson() => {'workout_exercise_id': workoutExerciseId, 'position': position, 'reps': reps, 'weight_kg': weightKg};
}
