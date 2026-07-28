import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';
import 'package:vitta/app/presentation/general/load_trigger.dart';
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

  bool get isViewingToday => state.date == _today;

  @override
  void onInit() => loadToday();

  Future<void> loadToday({LoadTrigger trigger = .replace}) => _loadDate(_today, trigger: trigger);

  Future<void> refresh({LoadTrigger trigger = .replace}) => _loadDate(state.date, trigger: trigger);

  Future<void> goToPreviousDay() => _goToDate(state.date.subtract(const Duration(days: 1)));

  Future<void> goToNextDay() => _goToDate(state.date.add(const Duration(days: 1)));

  Future<void> goToDate(DateTime date) => _goToDate(_dateOnly(date));

  Future<void> _goToDate(DateTime date) {
    emit(state.copyWith(date: date));
    return _loadDate(date);
  }

  Future<void> _loadDate(DateTime date, {LoadTrigger trigger = .replace}) async {
    final dailyGoalMl = _waterLocalDataSource.getDailyGoalMl();
    final dailyWaterResult = await withLoadingOverlay(
      () => _getDailyWaterUseCase(date: date),
      showOverlay: trigger.showsOverlay && state.isLoaded,
      showLoadingEvent: WaterShowLoading(),
      hideLoadingEvent: WaterHideLoading(),
    );
    dailyWaterResult.when(
      (error) => emitPresentation(WaterError(message: error.message)),
      (value) => emit(WaterState(date: date, dailyWater: value, dailyGoalMl: dailyGoalMl)),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> addWater({required double amountMl}) async {
    final loggedDate = state.date;
    final optimistic = WaterLog(id: 'optimistic-${_optimisticSeq++}', loggedDate: loggedDate, amountMl: amountMl);
    emit(state.copyWith(dailyWater: DailyWater(entries: [...state.dailyWater.entries, optimistic])));
    final loggedResult = await _logWaterUseCase(loggedDate: loggedDate, amountMl: amountMl);
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
    await refresh();
  }
}
