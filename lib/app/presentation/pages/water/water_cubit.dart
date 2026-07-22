import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';
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
           isLoaded: false,
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

  int _optimisticSeq = 0;

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  DateTime get _today => _dateOnly(DateTime.now());

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => loadToday();

  Future<void> loadToday() async {
    final dailyGoalMl = _waterLocalDataSource.getDailyGoalMl();
    final dailyWaterResult = await withLoadingOverlay(
      () => _getDailyWaterUseCase(date: _today),
      showOverlay: state.isLoaded,
      showLoadingEvent: WaterShowLoading(),
      hideLoadingEvent: WaterHideLoading(),
    );
    dailyWaterResult.when(
      (error) => emitPresentation(WaterError(message: error.message)),
      (value) => emit(WaterState(date: _today, dailyWater: value, dailyGoalMl: dailyGoalMl)),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> addWater({required double amountMl}) async {
    final optimistic = WaterLog(id: 'optimistic-${_optimisticSeq++}', loggedDate: _today, amountMl: amountMl);
    emit(state.copyWith(dailyWater: DailyWater(entries: [...state.dailyWater.entries, optimistic])));
    final loggedResult = await _logWaterUseCase(loggedDate: _today, amountMl: amountMl);
    loggedResult.when(
      (error) {
        emit(state.copyWith(dailyWater: DailyWater(entries: _without(optimistic.id))));
        emitPresentation(WaterError(message: error.message));
      },
      (saved) {
        Log.action('water_logged', data: {'amount_ml': amountMl});
        emit(
          state.copyWith(
            dailyWater: DailyWater(
              entries: [
                for (final entry in state.dailyWater.entries)
                  if (entry.id == optimistic.id) saved else entry,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteLog({required String logId}) async {
    final previous = state.dailyWater;
    emit(state.copyWith(dailyWater: DailyWater(entries: _without(logId))));
    final deletedResult = await _deleteWaterLogUseCase(logId: logId);
    deletedResult.when((error) {
      emit(state.copyWith(dailyWater: previous));
      emitPresentation(WaterError(message: error.message));
    }, (_) => Log.action('water_log_deleted'));
  }

  List<WaterLog> _without(String logId) => [
    for (final entry in state.dailyWater.entries)
      if (entry.id != logId) entry,
  ];

  Future<void> changeDailyGoal({required double goalMl}) async {
    await _waterLocalDataSource.saveDailyGoalMl(goalMl);
    Log.action('water_goal_changed', data: {'goal_ml': goalMl});
    await loadToday();
  }
}
