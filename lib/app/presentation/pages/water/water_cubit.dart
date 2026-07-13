import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_presentation_event.dart';
import 'package:vitta/app/presentation/pages/water/water_state.dart';

class WaterCubit extends PresentationCubit<WaterState, WaterPresentationEvent> {
  WaterCubit({
    required this._getDailyWaterUseCase,
    required this._logWaterUseCase,
    required this._deleteWaterLogUseCase,
    required this._waterLocalDataSource,
    required this._getAppSettingsUseCase,
  }) : super(
         WaterState(
           date: _dateOnly(DateTime.now()),
           dailyWater: const DailyWater(entries: []),
           dailyGoalMl: WaterLocalDataSource.defaultDailyGoalMl,
         ),
       );

  final GetDailyWaterUseCase _getDailyWaterUseCase;
  final LogWaterUseCase _logWaterUseCase;
  final DeleteWaterLogUseCase _deleteWaterLogUseCase;
  final WaterLocalDataSource _waterLocalDataSource;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  DateTime get _today => _dateOnly(DateTime.now());

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => loadToday();

  Future<void> loadToday() async {
    emitPresentation(WaterShowLoading());
    final dailyGoalMl = _waterLocalDataSource.getDailyGoalMl();
    final dailyWaterResult = await _getDailyWaterUseCase(date: _today);
    emitPresentation(WaterHideLoading());
    dailyWaterResult.when(
      (error) => emitPresentation(WaterError(message: error.message)),
      (value) => emit(WaterState(date: _today, dailyWater: value, dailyGoalMl: dailyGoalMl)),
    );
  }

  Future<void> addWater({required double amountMl}) async {
    final loggedResult = await _logWaterUseCase(loggedDate: _today, amountMl: amountMl);
    await loggedResult.when(
      (error) => Future.sync(() => emitPresentation(WaterError(message: error.message))),
      (_) => loadToday(),
    );
  }

  Future<void> deleteLog({required String logId}) async {
    final deletedResult = await _deleteWaterLogUseCase(logId: logId);
    await deletedResult.when(
      (error) => Future.sync(() => emitPresentation(WaterError(message: error.message))),
      (_) => loadToday(),
    );
  }

  Future<void> changeDailyGoal({required double goalMl}) async {
    await _waterLocalDataSource.saveDailyGoalMl(goalMl);
    await loadToday();
  }
}
