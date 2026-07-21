import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/body_weight/datasources/supabase/supabase_body_weight_datasource.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

class BodyWeightRepository {
  BodyWeightRepository({required this._supabaseBodyWeightDataSource});

  final SupabaseBodyWeightDataSource _supabaseBodyWeightDataSource;

  Future<Result<VTError, BodyWeightLog>> logBodyWeight({required DateTime loggedDate, required double weightKg}) =>
      _supabaseBodyWeightDataSource.logBodyWeight(loggedDate: loggedDate, weightKg: weightKg);

  Future<Result<VTError, List<BodyWeightLog>>> getRecentLogs({required int days}) => _supabaseBodyWeightDataSource.getRecentLogs(days: days);

  Future<Result<VTError, List<BodyWeightLog>>> getLogsInRange({required DateTime from, required DateTime to}) =>
      _supabaseBodyWeightDataSource.getLogsInRange(from: from, to: to);

  Future<Result<VTError, BodyWeightLog?>> getLatest() => _supabaseBodyWeightDataSource.getLatest();

  Future<Result<VTError, void>> deleteBodyWeightLog({required String logId}) => _supabaseBodyWeightDataSource.deleteBodyWeightLog(logId: logId);
}
