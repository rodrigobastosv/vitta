import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_latest_body_weight_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_recent_body_weight_logs_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/log_body_weight_use_case.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/use_cases/get_home_layout_use_case.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/domain/log_reminders/use_cases/sync_log_reminders_use_case.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/use_cases/complete_reminder_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/get_reminders_in_range_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/log_sleep_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_routine_cycle_use_case.dart';
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
    required this._getRoutineCycleUseCase,
    required this._getRecentSleepLogsUseCase,
    required this._getSleepGoalUseCase,
    required this._getLatestBodyWeightUseCase,
    required this._getRecentBodyWeightLogsUseCase,
    required this._getAppSettingsUseCase,
    required this._logWaterUseCase,
    required this._completeReminderUseCase,
    required this._logSleepUseCase,
    required this._logBodyWeightUseCase,
    required this._syncLogRemindersUseCase,
    required this._notificationService,
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
  final GetRoutineCycleUseCase _getRoutineCycleUseCase;
  final GetRecentSleepLogsUseCase _getRecentSleepLogsUseCase;
  final GetSleepGoalUseCase _getSleepGoalUseCase;
  final GetLatestBodyWeightUseCase _getLatestBodyWeightUseCase;
  final GetRecentBodyWeightLogsUseCase _getRecentBodyWeightLogsUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final LogWaterUseCase _logWaterUseCase;
  final CompleteReminderUseCase _completeReminderUseCase;
  final LogSleepUseCase _logSleepUseCase;
  final LogBodyWeightUseCase _logBodyWeightUseCase;
  final SyncLogRemindersUseCase _syncLogRemindersUseCase;
  final NotificationService _notificationService;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  double get sleepGoalHours => _getSleepGoalUseCase();

  DateTime get _today => _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

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
        final isSleepLoggedToday = await _loadSleep(today);
        await _loadWeight();
        await _syncLogReminders(isSleepLoggedToday: isSleepLoggedToday);
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
    if (!state.layout.heroes.contains(HomeFeature.workout) || state.hasWorkoutToday) {
      return;
    }
    final cycleResult = await _getRoutineCycleUseCase();
    cycleResult.when((_) {}, (value) => emit(state.copyWith(nextRoutine: value.next)));
  }

  Future<bool> _loadSleep(DateTime today) async {
    final sleepLogsResult = await _getRecentSleepLogsUseCase(days: 2);
    return sleepLogsResult.when((_) => false, (value) {
      if (value.isEmpty) {
        return false;
      }
      emit(state.copyWith(lastNightHours: value.first.duration.inMinutes / 60));
      return value.any((log) => _dateOnly(log.loggedDate) == today);
    });
  }

  Future<void> _syncLogReminders({required bool isSleepLoggedToday}) {
    final loggedMeals = state.dailyMacros.entries.map((entry) => entry.log.mealType).toSet();
    return _syncLogRemindersUseCase(
      loggedByTracker: {
        for (final tracker in LogReminderTracker.values)
          tracker: switch (tracker) {
            .water => state.consumedMl > 0,
            .sleep => isSleepLoggedToday,
            _ => loggedMeals.contains(tracker.mealType),
          },
      },
    );
  }

  Future<void> _loadWeight() async {
    final latestResult = await _getLatestBodyWeightUseCase();
    latestResult.when((_) {}, (value) => emit(state.copyWith(latestWeightKg: value?.weightKg)));
    if (!state.layout.heroes.contains(HomeFeature.bodyWeight)) {
      return;
    }
    final recentLogsResult = await _getRecentBodyWeightLogsUseCase(days: _weightTrendDays);
    recentLogsResult.when((_) {}, (value) => emit(state.copyWith(weightLogs: value)));
  }

  Future<void> addWater({required double amountMl}) async {
    final previousMl = state.consumedMl;
    emit(state.copyWith(consumedMl: previousMl + amountMl));
    final loggedResult = await _logWaterUseCase(loggedDate: _today, amountMl: amountMl);
    loggedResult.when((error) {
      emit(state.copyWith(consumedMl: previousMl));
      emitPresentation(HomeError(message: error.message));
    }, (_) => Log.action('water_logged', data: {'amount_ml': amountMl}));
  }

  // The hero only lists open reminders, so ticking one here is one-way: it
  // leaves the list the moment it is done.
  Future<void> completeReminder({required Reminder reminder}) async {
    final previous = state.reminders;
    emit(
      state.copyWith(
        reminders: [
          for (final item in previous)
            if (item.id == reminder.id) item.toggledCompletion(completed: true) else item,
        ],
      ),
    );
    final completionResult = await _completeReminderUseCase(reminder: reminder, completed: true);
    final completion = completionResult.when((error) {
      emit(state.copyWith(reminders: previous));
      emitPresentation(HomeError(message: error.message));
      return null;
    }, (value) => value);
    if (completion == null) {
      return;
    }
    Log.action('reminder_completed', data: {'completed': true});
    await _notificationService.cancel(reminder.notificationId);
    final reminders = [
      for (final item in state.reminders)
        if (item.id == completion.reminder.id) completion.reminder else item,
    ];
    final next = completion.nextOccurrence;
    emit(state.copyWith(reminders: [...reminders, if (next != null && _dateOnly(next.dueDate) == _today) next]));
  }

  Future<void> logSleep({required DateTime bedTime, required DateTime wakeTime, int? qualityRating}) async {
    final loggedResult = await _logSleepUseCase(bedTime: bedTime, wakeTime: wakeTime, qualityRating: qualityRating);
    await loggedResult.when((error) => Future.sync(() => emitPresentation(HomeError(message: error.message))), (_) {
      Log.action('sleep_logged', data: {'quality': qualityRating});
      return _loadSleep(_today);
    });
  }

  Future<void> logBodyWeight({required DateTime loggedDate, required double weightKg}) async {
    final loggedResult = await _logBodyWeightUseCase(loggedDate: loggedDate, weightKg: weightKg);
    await loggedResult.when((error) => Future.sync(() => emitPresentation(HomeError(message: error.message))), (_) {
      Log.action('body_weight_logged', data: {'weight_kg': weightKg});
      return _loadWeight();
    });
  }
}
