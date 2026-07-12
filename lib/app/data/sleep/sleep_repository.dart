import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/datasources/supabase_sleep_datasource.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class SleepRepository {
  SleepRepository({required this._supabaseSleepDataSource});

  final SupabaseSleepDataSource _supabaseSleepDataSource;

  Future<Result<VTError, SleepLog>> logSleep({required DateTime bedTime, required DateTime wakeTime, int? qualityRating}) =>
      _supabaseSleepDataSource.logSleep(bedTime: bedTime, wakeTime: wakeTime, qualityRating: qualityRating);

  Future<Result<VTError, List<SleepLog>>> getRecentSleepLogs({required int days}) =>
      _supabaseSleepDataSource.getRecentLogs(days: days);

  Future<Result<VTError, void>> deleteSleepLog({required String logId}) => _supabaseSleepDataSource.deleteSleepLog(logId: logId);
}
