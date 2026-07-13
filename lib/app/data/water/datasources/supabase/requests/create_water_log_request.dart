class CreateWaterLogRequest {
  CreateWaterLogRequest({required this.userId, required this.loggedDate, required this.amountMl});

  final String userId;
  final DateTime loggedDate;
  final double amountMl;

  Map<String, dynamic> toJson() => {'user_id': userId, 'logged_date': loggedDate.toIso8601String().split('T').first, 'amount_ml': amountMl};
}
