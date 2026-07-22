import 'package:vitta/app/domain/sleep/entities/sleep_log_source.dart';

class CreateSleepLogRequest {
  CreateSleepLogRequest({
    required this.userId,
    required this.bedTime,
    required this.wakeTime,
    this.qualityRating,
    this.source = .manual,
    this.externalId,
  });

  final String userId;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int? qualityRating;
  final SleepLogSource source;
  final String? externalId;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'logged_date': DateTime(wakeTime.year, wakeTime.month, wakeTime.day).toIso8601String().split('T').first,
    'bed_time': bedTime.toUtc().toIso8601String(),
    'wake_time': wakeTime.toUtc().toIso8601String(),
    'quality_rating': qualityRating,
    'source': source.wireValue,
    'external_id': externalId,
  };
}
