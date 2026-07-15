import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/supabase/supabase_water_datasource.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

class WaterRepository {
  WaterRepository({required this._supabaseWaterDataSource, required this._waterLocalDataSource});

  final SupabaseWaterDataSource _supabaseWaterDataSource;
  final WaterLocalDataSource _waterLocalDataSource;

  double getDailyGoalMl() => _waterLocalDataSource.getDailyGoalMl();

  Future<Result<VTError, WaterLog>> logWater({required DateTime loggedDate, required double amountMl}) =>
      _supabaseWaterDataSource.logWater(loggedDate: loggedDate, amountMl: amountMl);

  Future<Result<VTError, DailyWater>> getDailyWater({required DateTime date}) async {
    final dailyLogResult = await _supabaseWaterDataSource.getDailyLog(date: date);
    return dailyLogResult.when(Failure.new, (value) => Success(DailyWater(entries: value)));
  }

  Future<Result<VTError, Map<DateTime, DailyWater>>> getWaterInRange({required DateTime from, required DateTime to}) async {
    final logsResult = await _supabaseWaterDataSource.getLogsInRange(from: from, to: to);
    return logsResult.when(Failure.new, (logs) => Success(_groupByDate(logs)));
  }

  Map<DateTime, DailyWater> _groupByDate(List<WaterLog> logs) {
    final logsByDate = <DateTime, List<WaterLog>>{};
    for (final log in logs) {
      logsByDate.putIfAbsent(log.loggedDate, () => []).add(log);
    }
    return {for (final MapEntry(:key, :value) in logsByDate.entries) key: DailyWater(entries: value)};
  }

  Future<Result<VTError, void>> deleteWaterLog({required String logId}) => _supabaseWaterDataSource.deleteWaterLog(logId: logId);
}
