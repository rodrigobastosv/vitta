import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_daily_workouts_in_range_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_state.dart';

class WorkoutHistoryCubit extends PresentationCubit<WorkoutHistoryState, WorkoutHistoryPresentationEvent> {
  WorkoutHistoryCubit({required this._getDailyWorkoutsInRangeUseCase, required this._getAppSettingsUseCase})
    : super(WorkoutHistoryState(isLoaded: false, month: _monthOf(DateTime.now())));

  final GetDailyWorkoutsInRangeUseCase _getDailyWorkoutsInRangeUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  bool get isViewingCurrentMonth => state.month == _monthOf(DateTime.now());

  List<DateTime> get trendDays {
    final to = _dateOnly(DateTime.now());
    return [for (var offset = state.trendRange.days - 1; offset >= 0; offset--) to.subtract(Duration(days: offset))];
  }

  @override
  void onInit() => refresh();

  Future<void> refresh() async {
    emitPresentation(WorkoutHistoryShowLoading());
    await _loadMonth(state.month);
    await _loadTrend(state.trendRange);
    emitPresentation(WorkoutHistoryHideLoading());
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> goToPreviousMonth() => _changeMonth(-1);

  Future<void> goToNextMonth() => _changeMonth(1);

  Future<void> _changeMonth(int monthDelta) async {
    final month = DateTime(state.month.year, state.month.month + monthDelta);
    emit(state.copyWith(month: month));
    emitPresentation(WorkoutHistoryShowLoading());
    await _loadMonth(month);
    emitPresentation(WorkoutHistoryHideLoading());
  }

  Future<void> changeTrendRange(TrendRange trendRange) async {
    emit(state.copyWith(trendRange: trendRange));
    emitPresentation(WorkoutHistoryShowLoading());
    await _loadTrend(trendRange);
    emitPresentation(WorkoutHistoryHideLoading());
  }

  Future<void> _loadMonth(DateTime month) async {
    final workoutsResult = await _getDailyWorkoutsInRangeUseCase(from: month, to: DateTime(month.year, month.month + 1, 0));
    workoutsResult.when(
      (error) => emitPresentation(WorkoutHistoryError(message: error.message)),
      (workoutsByDate) => emit(state.copyWith(workoutsInMonth: workoutsByDate, isLoaded: true)),
    );
  }

  Future<void> _loadTrend(TrendRange trendRange) async {
    final to = _dateOnly(DateTime.now());
    final workoutsResult = await _getDailyWorkoutsInRangeUseCase(
      from: to.subtract(Duration(days: trendRange.days - 1)),
      to: to,
    );
    workoutsResult.when(
      (error) => emitPresentation(WorkoutHistoryError(message: error.message)),
      (workoutsByDate) => emit(state.copyWith(workoutsInTrendRange: workoutsByDate)),
    );
  }
}
