class CreateSleepLogRequest {
  CreateSleepLogRequest({required this.userId, required this.bedTime, required this.wakeTime, this.qualityRating});

  final String userId;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int? qualityRating;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'logged_date': DateTime(wakeTime.year, wakeTime.month, wakeTime.day).toIso8601String().split('T').first,
    'bed_time': bedTime.toUtc().toIso8601String(),
    'wake_time': wakeTime.toUtc().toIso8601String(),
    'quality_rating': qualityRating,
  };
}
