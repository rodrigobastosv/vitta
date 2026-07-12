import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/water/datasources/requests/create_water_log_request.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

class SupabaseWaterDataSource {
  SupabaseWaterDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, WaterLog>> logWater({required DateTime loggedDate, required double amountMl}) async {
    try {
      final request = CreateWaterLogRequest(userId: _supabaseService.currentUserId, loggedDate: loggedDate, amountMl: amountMl);
      final row = await _supabaseService.from('water_logs').insert(request.toJson()).select().single();
      return Success(_waterLogFromRow(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log water', cause: error));
    }
  }

  Future<Result<VTError, List<WaterLog>>> getDailyLog({required DateTime date}) async {
    try {
      final rows = await _supabaseService
          .from('water_logs')
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .eq('logged_date', date.toIso8601String().split('T').first)
          .order('created_at');
      return Success(rows.map(_waterLogFromRow).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load water logs for $date', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteWaterLog({required String logId}) async {
    try {
      await _supabaseService.from('water_logs').delete().eq('id', logId).eq('user_id', _supabaseService.currentUserId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete water log $logId', cause: error));
    }
  }

  WaterLog _waterLogFromRow(Map<String, dynamic> row) => WaterLog(
    id: row['id'] as String,
    loggedDate: DateTime.parse(row['logged_date'] as String),
    amountMl: (row['amount_ml'] as num).toDouble(),
  );
}
