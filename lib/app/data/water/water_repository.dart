import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/water/datasources/supabase_water_datasource.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

class WaterRepository {
  WaterRepository({required SupabaseWaterDataSource supabaseWaterDataSource}) : _supabaseWaterDataSource = supabaseWaterDataSource;

  final SupabaseWaterDataSource _supabaseWaterDataSource;

  Future<Result<VTError, WaterLog>> logWater({required DateTime loggedDate, required double amountMl}) =>
      _supabaseWaterDataSource.logWater(loggedDate: loggedDate, amountMl: amountMl);

  Future<Result<VTError, DailyWater>> getDailyWater({required DateTime date}) async {
    final dailyLogResult = await _supabaseWaterDataSource.getDailyLog(date: date);
    return dailyLogResult.when(Failure.new, (value) => Success(DailyWater(entries: value)));
  }

  Future<Result<VTError, void>> deleteWaterLog({required String logId}) => _supabaseWaterDataSource.deleteWaterLog(logId: logId);
}
