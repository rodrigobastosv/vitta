import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log_source.dart';

class SleepLog extends Equatable {
  const SleepLog({
    required this.id,
    required this.loggedDate,
    required this.bedTime,
    required this.wakeTime,
    this.qualityRating,
    this.source = .manual,
  });

  factory SleepLog.fromMap(Map<String, dynamic> row) => SleepLog(
    id: row['id'] as String,
    loggedDate: DateTime.parse(row['logged_date'] as String),
    bedTime: DateTime.parse(row['bed_time'] as String).toLocal(),
    wakeTime: DateTime.parse(row['wake_time'] as String).toLocal(),
    qualityRating: row['quality_rating'] as int?,
    source: SleepLogSource.fromWire(row['source'] as String?),
  );

  final String id;
  final DateTime loggedDate;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int? qualityRating;
  final SleepLogSource source;

  Duration get duration => wakeTime.difference(bedTime);

  @override
  List<Object?> get props => [id, loggedDate, bedTime, wakeTime, qualityRating, source];
}
