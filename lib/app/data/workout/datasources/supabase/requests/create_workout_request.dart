class CreateWorkoutRequest {
  CreateWorkoutRequest({required this.userId, required this.performedDate, this.notes});

  final String userId;
  final DateTime performedDate;
  final String? notes;

  Map<String, dynamic> toJson() => {'user_id': userId, 'performed_date': performedDate.toIso8601String().split('T').first, 'notes': notes};
}
