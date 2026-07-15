class UpdateWorkoutSetRequest {
  UpdateWorkoutSetRequest({required this.reps, required this.weightKg});

  final int reps;
  final double weightKg;

  Map<String, dynamic> toJson() => {'reps': reps, 'weight_kg': weightKg};
}
