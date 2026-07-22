class UpdateWorkoutSetRequest {
  UpdateWorkoutSetRequest({this.reps, this.weightKg = 0, this.durationSeconds, this.distanceMeters});

  final int? reps;
  final double weightKg;
  final int? durationSeconds;
  final double? distanceMeters;

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight_kg': weightKg,
    'duration_seconds': durationSeconds,
    'distance_meters': distanceMeters,
  };
}
