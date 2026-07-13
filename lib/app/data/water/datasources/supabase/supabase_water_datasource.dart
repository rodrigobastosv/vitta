import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/water/datasources/supabase/requests/create_water_log_request.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

class SupabaseWaterDataSource {
  SupabaseWaterDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, WaterLog>> logWater({required DateTime loggedDate, required double amountMl}) async {
    try {
      final request = CreateWaterLogRequest(userId: _supabaseService.currentUserId, loggedDate: loggedDate, amountMl: amountMl);
      final row = await _supabaseService.from(.waterLogs).insert(request.toJson()).select().single();
      return Success(WaterLog.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log water', cause: error));
    }
  }

  Future<Result<VTError, List<WaterLog>>> getDailyLog({required DateTime date}) async {
    try {
      final rows = await _supabaseService
          .from(.waterLogs)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .eq('logged_date', date.toIso8601String().split('T').first)
          .order('created_at');
      return Success(rows.map(WaterLog.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load water logs for $date', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteWaterLog({required String logId}) async {
    try {
      await _supabaseService.from(.waterLogs).delete().eq('id', logId).eq('user_id', _supabaseService.currentUserId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete water log $logId', cause: error));
    }
  }
}
