import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/data/water/water_local_datasource.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';
import 'package:vitta/app/presentation/pages/water/water_state.dart';

class WaterCubit extends Cubit<WaterState> {
  WaterCubit({
    required GetDailyWaterUseCase getDailyWaterUseCase,
    required LogWaterUseCase logWaterUseCase,
    required DeleteWaterLogUseCase deleteWaterLogUseCase,
    required WaterLocalDataSource waterLocalDataSource,
  }) : _getDailyWaterUseCase = getDailyWaterUseCase,
       _logWaterUseCase = logWaterUseCase,
       _deleteWaterLogUseCase = deleteWaterLogUseCase,
       _waterLocalDataSource = waterLocalDataSource,
       super(const WaterLoading());

  final GetDailyWaterUseCase _getDailyWaterUseCase;
  final LogWaterUseCase _logWaterUseCase;
  final DeleteWaterLogUseCase _deleteWaterLogUseCase;
  final WaterLocalDataSource _waterLocalDataSource;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> loadToday() async {
    emit(const WaterLoading());
    final dailyGoalMl = _waterLocalDataSource.getDailyGoalMl();
    final dailyWater = await _getDailyWaterUseCase(date: _today);
    switch (dailyWater) {
      case Failure(:final error):
        emit(WaterError(message: error.message));
      case Success(:final value):
        emit(WaterLoaded(date: _today, dailyWater: value, dailyGoalMl: dailyGoalMl));
    }
  }

  Future<void> addWater({required double amountMl}) async {
    final logged = await _logWaterUseCase(loggedDate: _today, amountMl: amountMl);
    switch (logged) {
      case Failure(:final error):
        emit(WaterError(message: error.message));
      case Success():
        await loadToday();
    }
  }

  Future<void> deleteLog({required String logId}) async {
    final deleted = await _deleteWaterLogUseCase(logId: logId);
    switch (deleted) {
      case Failure(:final error):
        emit(WaterError(message: error.message));
      case Success():
        await loadToday();
    }
  }

  Future<void> changeDailyGoal({required double goalMl}) async {
    await _waterLocalDataSource.saveDailyGoalMl(goalMl);
    await loadToday();
  }
}
