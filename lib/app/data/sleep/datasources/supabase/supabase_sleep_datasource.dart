import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/sleep/datasources/supabase/requests/create_sleep_log_request.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class SupabaseSleepDataSource {
  SupabaseSleepDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, SleepLog>> logSleep({required DateTime bedTime, required DateTime wakeTime, int? qualityRating}) async {
    try {
      final request = CreateSleepLogRequest(
        userId: _supabaseService.currentUserId,
        bedTime: bedTime,
        wakeTime: wakeTime,
        qualityRating: qualityRating,
      );
      final row = await _supabaseService.from(.sleepLogs).insert(request.toJson()).select().single();
      return Success(SleepLog.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log sleep', cause: error));
    }
  }

  Future<Result<VTError, List<SleepLog>>> getLogsInRange({required DateTime from, required DateTime to}) async {
    try {
      final rows = await _supabaseService
          .from(.sleepLogs)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .gte('logged_date', from.toIso8601String().split('T').first)
          .lte('logged_date', to.toIso8601String().split('T').first)
          .order('logged_date', ascending: true);
      return Success(rows.map(SleepLog.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load sleep logs', cause: error));
    }
  }

  Future<Result<VTError, List<SleepLog>>> getRecentLogs({required int days}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final sinceDate = DateTime(since.year, since.month, since.day);
      final rows = await _supabaseService
          .from(.sleepLogs)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .gte('logged_date', sinceDate.toIso8601String().split('T').first)
          .order('logged_date', ascending: false);
      return Success(rows.map(SleepLog.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load recent sleep logs', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteSleepLog({required String logId}) async {
    try {
      await _supabaseService.from(.sleepLogs).delete().eq('id', logId).eq('user_id', _supabaseService.currentUserId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete sleep log $logId', cause: error));
    }
  }
}
