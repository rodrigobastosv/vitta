import 'dart:async';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/logging_streak.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_cached_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macros_in_range_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/has_seen_diet_intro_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/mark_diet_intro_seen_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/update_food_log_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/sync/entities/sync_topic.dart';
import 'package:vitta/app/domain/sync/use_cases/watch_data_changes_use_case.dart';
import 'package:vitta/app/presentation/general/load_trigger.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

class DietCubit extends PresentationCubit<DietState, DietPresentationEvent> {
  DietCubit({
    required this._getDailyMacrosUseCase,
    required this._getCachedDailyMacrosUseCase,
    required this._deleteFoodLogUseCase,
    required this._updateFoodLogUseCase,
    required this._getMacroGoalsUseCase,
    required this._getMacrosInRangeUseCase,
    required this._getAppSettingsUseCase,
    required this._hasSeenDietIntroUseCase,
    required this._markDietIntroSeenUseCase,
    required this._watchDataChangesUseCase,
  }) : super(
         DietState(
           isLoaded: false,
           date: _dateOnly(DateTime.now()),
           dailyMacros: const DailyMacros(entries: []),
           macroGoals: MacroGoals.defaultGoals,
         ),
       );

  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final GetCachedDailyMacrosUseCase _getCachedDailyMacrosUseCase;
  final DeleteFoodLogUseCase _deleteFoodLogUseCase;
  final UpdateFoodLogUseCase _updateFoodLogUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;
  final GetMacrosInRangeUseCase _getMacrosInRangeUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final HasSeenDietIntroUseCase _hasSeenDietIntroUseCase;
  final MarkDietIntroSeenUseCase _markDietIntroSeenUseCase;
  final WatchDataChangesUseCase _watchDataChangesUseCase;

  StreamSubscription<SyncTopic>? _changes;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  // Far enough back that a streak worth showing off is never truncated by the
  // window it was counted in.
  static const int _streakLookbackDays = 90;

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  DateTime get _today => _dateOnly(DateTime.now());

  bool get isViewingToday => state.date == _today;

  @override
  void onInit() {
    if (!_hasSeenDietIntroUseCase()) {
      emitPresentation(DietShowIntro());
    }
    loadToday();
    _changes = _watchDataChangesUseCase(topics: const {SyncTopic.diet}).listen((_) => _loadDate(state.date, trigger: .quiet));
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }

  Future<void> markIntroSeen() => _markDietIntroSeenUseCase();

  Future<void> loadToday() => _loadDate(_today);

  Future<void> refresh({LoadTrigger trigger = .replace}) => _loadDate(state.date, trigger: trigger);

  Future<void> goToPreviousDay() => _goToDate(state.date.subtract(const Duration(days: 1)));

  Future<void> goToNextDay() => _goToDate(state.date.add(const Duration(days: 1)));

  Future<void> goToDate(DateTime date) => _goToDate(_dateOnly(date));

  Future<void> _goToDate(DateTime date) {
    emit(state.copyWith(date: date));
    return _loadDate(date);
  }

  /// A day the device has seen before is drawn from cache first, so opening the
  /// page (or paging to another day) starts on real content instead of a
  /// skeleton. The day already on screen is never rewound to its cached copy —
  /// state is fresher than the cache the moment a log is added or deleted.
  Future<void> _loadDate(DateTime date, {LoadTrigger trigger = .replace}) async {
    final macroGoals = _getMacroGoalsUseCase();
    final isAlreadyShown = state.isLoaded && state.date == date;
    final cachedMacros = isAlreadyShown ? null : _getCachedDailyMacrosUseCase(date: date);
    if (cachedMacros != null) {
      emit(state.copyWith(isLoaded: true, date: date, dailyMacros: cachedMacros, macroGoals: macroGoals));
    }
    final calendarContext = _loadCalendarContext(date);
    final dailyMacrosResult = await withLoadingOverlay(
      () => _getDailyMacrosUseCase(date: date),
      showOverlay: trigger.showsOverlay && state.isLoaded && cachedMacros == null,
      showLoadingEvent: DietShowLoading(),
      hideLoadingEvent: DietHideLoading(),
    );
    dailyMacrosResult.when(
      (error) => emitPresentation(DietError(message: error.message, date: date)),
      (value) => emit(state.copyWith(isLoaded: true, date: date, dailyMacros: value, macroGoals: macroGoals)),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
    await calendarContext;
  }

  /// The days behind the week strip and the streak, read alongside the day
  /// itself rather than after it. Non-blocking on purpose, like the workout
  /// routine cycle: a failure here hides the strip and the streak rather than
  /// putting an error over a day that loaded perfectly well.
  Future<void> _loadCalendarContext(DateTime date) async {
    final today = _today;
    final streakStart = DateTime(today.year, today.month, today.day - _streakLookbackDays);
    final weekStart = DateTime(date.year, date.month, date.day - 7);
    final weekEnd = DateTime(date.year, date.month, date.day + 7);
    final from = weekStart.isBefore(streakStart) ? weekStart : streakStart;
    final to = weekEnd.isAfter(today) ? weekEnd : today;
    final macrosResult = await _getMacrosInRangeUseCase(from: from, to: to);
    macrosResult.when((_) => null, (loaded) {
      // Compared before emitting because Cubit.emit only de-duplicates *after*
      // its first emission - without this an account with nothing logged gets a
      // rebuild that changes nothing on every single day load.
      final next = state.copyWith(macrosByDate: _mergeRange(loaded, from: from, to: to), streak: _streakFrom(loaded));
      if (next != state) {
        emit(next);
      }
    });
  }

  /// Days inside the range just read are *replaced*, not merged over — a day
  /// whose last entry was deleted comes back absent, and merging would leave its
  /// dot on the strip and its link in the streak forever. Days outside the range
  /// are kept, which is what makes the map accumulate.
  Map<DateTime, DailyMacros> _mergeRange(Map<DateTime, DailyMacros> loaded, {required DateTime from, required DateTime to}) =>
      Map<DateTime, DailyMacros>.of(state.macrosByDate)
        ..removeWhere((day, _) => !day.isBefore(from) && !day.isAfter(to))
        ..addAll(loaded);

  LoggingStreak _streakFrom(Map<DateTime, DailyMacros> loaded) => LoggingStreak.from(loggedDays: loaded.keys.toSet(), today: _today);

  Future<void> loadMonthMacros(DateTime month) async {
    final from = DateTime(month.year, month.month);
    final to = DateTime(month.year, month.month + 1, 0);
    final monthlyMacrosResult = await _getMacrosInRangeUseCase(from: from, to: to);
    monthlyMacrosResult.when((_) => null, (loaded) => emit(state.copyWith(macrosByDate: _mergeRange(loaded, from: from, to: to))));
  }

  Future<Result<VTError, FoodLog>> updateLog({required String logId, required MealType mealType, required LoggedQuantity quantity}) async {
    final updatedResult = await _updateFoodLogUseCase(logId: logId, mealType: mealType, quantity: quantity);
    final error = updatedResult.when((error) => error, (_) => null);
    if (error == null) {
      Log.action('food_log_updated', data: {'meal': mealType.wireValue});
      await _loadDate(state.date);
    }
    return updatedResult;
  }

  Future<void> deleteLog({required String logId}) async {
    final deletedResult = await _deleteFoodLogUseCase(logId: logId);
    deletedResult.when((error) => emitPresentation(DietError(message: error.message, date: state.date)), (_) {
      Log.action('food_log_deleted');
      return _loadDate(state.date);
    });
  }
}
