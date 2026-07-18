import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/body_weight/datasources/supabase/requests/create_body_weight_log_request.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

class SupabaseBodyWeightDataSource {
  SupabaseBodyWeightDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, BodyWeightLog>> logBodyWeight({required DateTime loggedDate, required double weightKg}) async {
    try {
      final request = CreateBodyWeightLogRequest(userId: _supabaseService.currentUserId, loggedDate: loggedDate, weightKg: weightKg);
      final row = await _supabaseService.from(.bodyWeightLogs).insert(request.toJson()).select().single();
      return Success(BodyWeightLog.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log body weight', cause: error));
    }
  }

  Future<Result<VTError, List<BodyWeightLog>>> getRecentLogs({required int days}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final sinceDate = DateTime(since.year, since.month, since.day);
      final rows = await _supabaseService
          .from(.bodyWeightLogs)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .gte('logged_date', sinceDate.toIso8601String().split('T').first)
          .order('logged_date', ascending: false)
          .order('created_at', ascending: false);
      return Success(rows.map(BodyWeightLog.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load recent body weight logs', cause: error));
    }
  }

  Future<Result<VTError, List<BodyWeightLog>>> getLogsInRange({required DateTime from, required DateTime to}) async {
    try {
      final rows = await _supabaseService
          .from(.bodyWeightLogs)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .gte('logged_date', from.toIso8601String().split('T').first)
          .lte('logged_date', to.toIso8601String().split('T').first)
          .order('logged_date', ascending: true)
          .order('created_at', ascending: true);
      return Success(rows.map(BodyWeightLog.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load body weight logs', cause: error));
    }
  }

  Future<Result<VTError, BodyWeightLog?>> getLatest() async {
    try {
      final row = await _supabaseService
          .from(.bodyWeightLogs)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .order('logged_date', ascending: false)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return Success(row == null ? null : BodyWeightLog.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load the latest body weight', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteBodyWeightLog({required String logId}) async {
    try {
      await _supabaseService.from(.bodyWeightLogs).delete().eq('id', logId).eq('user_id', _supabaseService.currentUserId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete body weight log $logId', cause: error));
    }
  }
}
