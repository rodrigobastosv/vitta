class CreateWorkoutRequest {
  CreateWorkoutRequest({required this.userId, required this.performedDate, this.notes, this.routineId});

  final String userId;
  final DateTime performedDate;
  final String? notes;

  final String? routineId;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'performed_date': performedDate.toIso8601String().split('T').first,
    'notes': notes,
    'routine_id': routineId,
  };
}
