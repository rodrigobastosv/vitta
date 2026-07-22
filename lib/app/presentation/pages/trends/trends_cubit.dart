import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_body_weight_in_range_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macros_in_range_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_in_range_use_case.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_in_range_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_daily_workouts_in_range_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/trends/trends_presentation_event.dart';
import 'package:vitta/app/presentation/pages/trends/trends_state.dart';

class TrendsCubit extends PresentationCubit<TrendsState, TrendsPresentationEvent> {
  TrendsCubit({
    required this._getMacrosInRangeUseCase,
    required this._getMacroGoalsUseCase,
    required this._getWaterInRangeUseCase,
    required this._getWaterGoalUseCase,
    required this._getSleepInRangeUseCase,
    required this._getSleepGoalUseCase,
    required this._getDailyWorkoutsInRangeUseCase,
    required this._getBodyWeightInRangeUseCase,
    required this._getAppSettingsUseCase,
  }) : super(const TrendsState(isLoaded: false));

  final GetMacrosInRangeUseCase _getMacrosInRangeUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;
  final GetWaterInRangeUseCase _getWaterInRangeUseCase;
  final GetWaterGoalUseCase _getWaterGoalUseCase;
  final GetSleepInRangeUseCase _getSleepInRangeUseCase;
  final GetSleepGoalUseCase _getSleepGoalUseCase;
  final GetDailyWorkoutsInRangeUseCase _getDailyWorkoutsInRangeUseCase;
  final GetBodyWeightInRangeUseCase _getBodyWeightInRangeUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  List<DateTime> get days => _daysEndingToday(from: state.trendRange.days - 1, to: 0);

  @override
  void onInit() => refresh();

  Future<void> refresh() async {
    await withLoadingOverlay(
      () => _load(state.trendRange),
      showOverlay: state.isLoaded,
      showLoadingEvent: TrendsShowLoading(),
      hideLoadingEvent: TrendsHideLoading(),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> changeTrendRange(TrendRange trendRange) async {
    emit(state.copyWith(trendRange: trendRange));
    await refresh();
  }

  List<DateTime> _daysEndingToday({required int from, required int to}) {
    final today = _dateOnly(DateTime.now());
    return [for (var offset = from; offset >= to; offset--) today.subtract(Duration(days: offset))];
  }

  Future<void> _load(TrendRange trendRange) async {
    final currentDays = _daysEndingToday(from: trendRange.days - 1, to: 0);
    final previousDays = _daysEndingToday(from: trendRange.days * 2 - 1, to: trendRange.days);
    final from = previousDays.first;
    final to = currentDays.last;

    final macrosFuture = _getMacrosInRangeUseCase(from: from, to: to);
    final waterFuture = _getWaterInRangeUseCase(from: from, to: to);
    final sleepFuture = _getSleepInRangeUseCase(from: from, to: to);
    final workoutsFuture = _getDailyWorkoutsInRangeUseCase(from: from, to: to);
    final bodyWeightFuture = _getBodyWeightInRangeUseCase(from: from, to: to);

    final failures = <String>[];
    final caloriesByDate = _valuesOf(await macrosFuture, (macros) => macros.totalCalories, failures);
    final waterByDate = _valuesOf(await waterFuture, (water) => water.totalMl, failures);
    final sleepByDate = _valuesOf(await sleepFuture, (sleep) => sleep.totalHours, failures);
    final volumeByDate = _valuesOf(await workoutsFuture, (workout) => workout.volumeKg, failures);
    final weightByDate = _weightsOf(await bodyWeightFuture, failures);

    emit(
      state.copyWith(
        isLoaded: true,
        trends: {
          .nutrition: _trendOf(caloriesByDate, currentDays, previousDays, goal: _getMacroGoalsUseCase().calorieGoal),
          .water: _trendOf(waterByDate, currentDays, previousDays, goal: _getWaterGoalUseCase()),
          .sleep: _trendOf(sleepByDate, currentDays, previousDays, goal: _getSleepGoalUseCase()),
          .workout: _trendOf(volumeByDate, currentDays, previousDays),
          .bodyWeight: _trendOf(weightByDate, currentDays, previousDays),
        },
      ),
    );
    if (failures.isNotEmpty) {
      emitPresentation(TrendsError(message: failures.first));
    }
  }

  Map<DateTime, double> _valuesOf<T>(Result<VTError, Map<DateTime, T>> dailyResult, double Function(T daily) valueOf, List<String> failures) =>
      dailyResult.when(
        (error) {
          failures.add(error.message);
          return const {};
        },
        (dailyByDate) => {
          for (final entry in dailyByDate.entries)
            if (valueOf(entry.value) > 0) _dateOnly(entry.key): valueOf(entry.value),
        },
      );

  Map<DateTime, double> _weightsOf(Result<VTError, List<BodyWeightLog>> logsResult, List<String> failures) => logsResult.when(
    (error) {
      failures.add(error.message);
      return const {};
    },
    (logs) => {for (final log in logs) _dateOnly(log.loggedDate): log.weightKg},
  );

  AreaTrend _trendOf(Map<DateTime, double> valuesByDate, List<DateTime> currentDays, List<DateTime> previousDays, {double? goal}) => AreaTrend(
    days: currentDays,
    valuesByDate: {for (final day in currentDays) day: ?valuesByDate[day]},
    previousValuesByDate: {for (final day in previousDays) day: ?valuesByDate[day]},
    goal: goal,
  );
}
