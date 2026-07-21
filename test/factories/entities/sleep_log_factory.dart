import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

abstract class SleepLogFactory {
  static SleepLog build({String id = 'sleep-log-1', DateTime? loggedDate, DateTime? bedTime, DateTime? wakeTime, int? qualityRating}) => SleepLog(
    id: id,
    loggedDate: loggedDate ?? DateTime(2026, 7, 11),
    bedTime: bedTime ?? DateTime(2026, 7, 10, 22, 30),
    wakeTime: wakeTime ?? DateTime(2026, 7, 11, 6, 45),
    qualityRating: qualityRating,
  );
}
