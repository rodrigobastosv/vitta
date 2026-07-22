class CreateWorkoutSetRequest {
  CreateWorkoutSetRequest({
    required this.workoutExerciseId,
    required this.position,
    this.reps,
    this.weightKg = 0,
    this.durationSeconds,
    this.distanceMeters,
  });

  final String workoutExerciseId;
  final int position;
  final int? reps;
  final double weightKg;
  final int? durationSeconds;
  final double? distanceMeters;

  Map<String, dynamic> toJson() => {
    'workout_exercise_id': workoutExerciseId,
    'position': position,
    'reps': reps,
    'weight_kg': weightKg,
    'duration_seconds': durationSeconds,
    'distance_meters': distanceMeters,
  };
}
