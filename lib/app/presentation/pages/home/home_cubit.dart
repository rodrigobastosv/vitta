import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_latest_body_weight_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_recent_body_weight_logs_use_case.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/home/use_cases/get_home_layout_use_case.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/use_cases/get_reminders_in_range_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_goal_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_workouts_for_date_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_presentation_event.dart';
import 'package:vitta/app/presentation/pages/home/home_state.dart';

class HomeCubit extends PresentationCubit<HomeState, HomePresentationEvent> {
  HomeCubit({
    required GetUserUseCase getUserUseCase,
    required GetMacroGoalsUseCase getMacroGoalsUseCase,
    required GetHomeLayoutUseCase getHomeLayoutUseCase,
    required this._getDailyMacrosUseCase,
    required this._getDailyWaterUseCase,
    required this._getWaterGoalUseCase,
    required this._getRemindersInRangeUseCase,
    required this._getWorkoutsForDateUseCase,
    required this._getRecentSleepLogsUseCase,
    required this._getSleepGoalUseCase,
    required this._getLatestBodyWeightUseCase,
    required this._getRecentBodyWeightLogsUseCase,
    required this._getAppSettingsUseCase,
  }) : _getUserUseCase = getUserUseCase,
       _getMacroGoalsUseCase = getMacroGoalsUseCase,
       _getHomeLayoutUseCase = getHomeLayoutUseCase,
       super(
         HomeState(
           user: getUserUseCase(),
           dailyMacros: const DailyMacros(entries: []),
           macroGoals: getMacroGoalsUseCase(),
           layout: getHomeLayoutUseCase(),
           isLoaded: false,
         ),
       );

  static const _weightTrendDays = 60;

  final GetUserUseCase _getUserUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;
  final GetHomeLayoutUseCase _getHomeLayoutUseCase;
  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final GetDailyWaterUseCase _getDailyWaterUseCase;
  final GetWaterGoalUseCase _getWaterGoalUseCase;
  final GetRemindersInRangeUseCase _getRemindersInRangeUseCase;
  final GetWorkoutsForDateUseCase _getWorkoutsForDateUseCase;
  final GetRecentSleepLogsUseCase _getRecentSleepLogsUseCase;
  final GetSleepGoalUseCase _getSleepGoalUseCase;
  final GetLatestBodyWeightUseCase _getLatestBodyWeightUseCase;
  final GetRecentBodyWeightLogsUseCase _getRecentBodyWeightLogsUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  double get sleepGoalHours => _getSleepGoalUseCase();

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void onInit() => refresh();

  Future<void> refresh() async {
    final today = _today;
    await withLoadingOverlay(
      () async {
        final dailyMacrosResult = await _getDailyMacrosUseCase(date: today);
        dailyMacrosResult.when(
          (error) => emitPresentation(HomeError(message: error.message)),
          (value) => emit(
            state.copyWith(
              isLoaded: true,
              dailyMacros: value,
              macroGoals: _getMacroGoalsUseCase(),
              user: _getUserUseCase(),
              layout: _getHomeLayoutUseCase(),
            ),
          ),
        );

        await _loadWater(today);
        await _loadReminders(today);
        await _loadWorkout(today);
        await _loadSleep();
        await _loadWeight();
      },
      showOverlay: state.isLoaded,
      showLoadingEvent: HomeShowLoading(),
      hideLoadingEvent: HomeHideLoading(),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true, layout: _getHomeLayoutUseCase()));
    }
  }

  Future<void> _loadWater(DateTime today) async {
    final dailyWaterResult = await _getDailyWaterUseCase(date: today);
    dailyWaterResult.when((_) {}, (value) => emit(state.copyWith(consumedMl: value.totalMl, dailyGoalMl: _getWaterGoalUseCase())));
  }

  Future<void> _loadReminders(DateTime today) async {
    final remindersResult = await _getRemindersInRangeUseCase(from: today, to: today);
    remindersResult.when((_) {}, (value) {
      final due = [...?value[today]]..sort(_byRemindAt);
      emit(state.copyWith(reminders: due));
    });
  }

  int _byRemindAt(Reminder a, Reminder b) => switch ((a.remindAt, b.remindAt)) {
    (final aAt?, final bAt?) => aAt.compareTo(bAt),
    (null, _?) => 1,
    (_?, null) => -1,
    _ => 0,
  };

  Future<void> _loadWorkout(DateTime today) async {
    final workoutsResult = await _getWorkoutsForDateUseCase(date: today);
    workoutsResult.when((_) {}, (value) => emit(state.copyWith(workouts: value)));
  }

  Future<void> _loadSleep() async {
    final sleepLogsResult = await _getRecentSleepLogsUseCase(days: 2);
    sleepLogsResult.when((_) {}, (value) {
      if (value.isEmpty) {
        return;
      }
      emit(state.copyWith(lastNightHours: value.first.duration.inMinutes / 60));
    });
  }

  Future<void> _loadWeight() async {
    final latestResult = await _getLatestBodyWeightUseCase();
    latestResult.when((_) {}, (value) => emit(state.copyWith(latestWeightKg: value?.weightKg)));
    if (state.layout.hero != .bodyWeight) {
      return;
    }
    final recentLogsResult = await _getRecentBodyWeightLogsUseCase(days: _weightTrendDays);
    recentLogsResult.when((_) {}, (value) => emit(state.copyWith(weightLogs: value)));
  }
}
