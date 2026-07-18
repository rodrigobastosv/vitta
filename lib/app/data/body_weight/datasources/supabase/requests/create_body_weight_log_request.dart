class CreateBodyWeightLogRequest {
  CreateBodyWeightLogRequest({required this.userId, required this.loggedDate, required this.weightKg});

  final String userId;
  final DateTime loggedDate;
  final double weightKg;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'logged_date': loggedDate.toIso8601String().split('T').first,
    'weight_kg': weightKg,
  };
}
