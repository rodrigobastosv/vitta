import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/datasources/local/sleep_local_datasource.dart';
import 'package:vitta/app/data/sleep/datasources/supabase/supabase_sleep_datasource.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_import.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class SleepRepository {
  SleepRepository({required this._supabaseSleepDataSource, required this._sleepLocalDataSource});

  final SupabaseSleepDataSource _supabaseSleepDataSource;
  final SleepLocalDataSource _sleepLocalDataSource;

  double getDurationGoalHours() => _sleepLocalDataSource.getDurationGoalHours();

  Future<void> saveDurationGoalHours(double goalHours) => _sleepLocalDataSource.saveDurationGoalHours(goalHours);

  Future<Result<VTError, Map<DateTime, DailySleep>>> getSleepInRange({required DateTime from, required DateTime to}) async {
    final logsResult = await _supabaseSleepDataSource.getLogsInRange(from: from, to: to);
    return logsResult.when(Failure.new, (logs) => Success(_groupByDate(logs)));
  }

  Map<DateTime, DailySleep> _groupByDate(List<SleepLog> logs) {
    final logsByDate = <DateTime, List<SleepLog>>{};
    for (final log in logs) {
      logsByDate.putIfAbsent(log.loggedDate, () => []).add(log);
    }
    return {for (final MapEntry(:key, :value) in logsByDate.entries) key: DailySleep(entries: value)};
  }

  Future<Result<VTError, SleepLog>> logSleep({required DateTime bedTime, required DateTime wakeTime, int? qualityRating}) =>
      _supabaseSleepDataSource.logSleep(bedTime: bedTime, wakeTime: wakeTime, qualityRating: qualityRating);

  Future<Result<VTError, List<SleepLog>>> getRecentSleepLogs({required int days}) => _supabaseSleepDataSource.getRecentLogs(days: days);

  Future<Result<VTError, int>> importSleepLogs({required List<SleepImport> imports}) => _supabaseSleepDataSource.importSleepLogs(imports: imports);

  Future<Result<VTError, void>> deleteSleepLog({required String logId}) => _supabaseSleepDataSource.deleteSleepLog(logId: logId);
}
