import 'package:vitta/app/data/sleep/datasources/local/sleep_local_datasource.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_in_range_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_state.dart';

class SleepHistoryCubit extends PresentationCubit<SleepHistoryState, SleepHistoryPresentationEvent> {
  SleepHistoryCubit({required this._getSleepInRangeUseCase, required this._getSleepGoalUseCase})
    : super(SleepHistoryState(isLoaded: false, month: _monthOf(DateTime.now()), durationGoalHours: SleepLocalDataSource.defaultDurationGoalHours));

  final GetSleepInRangeUseCase _getSleepInRangeUseCase;
  final GetSleepGoalUseCase _getSleepGoalUseCase;

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool get isViewingCurrentMonth => state.month == _monthOf(DateTime.now());

  List<DateTime> get trendDays {
    final to = _dateOnly(DateTime.now());
    return [for (var offset = state.trendRange.days - 1; offset >= 0; offset--) to.subtract(Duration(days: offset))];
  }

  @override
  void onInit() => refresh();

  Future<void> refresh() async {
    emitPresentation(SleepHistoryShowLoading());
    emit(state.copyWith(durationGoalHours: _getSleepGoalUseCase()));
    await _loadMonth(state.month);
    await _loadTrend(state.trendRange);
    emitPresentation(SleepHistoryHideLoading());
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> goToPreviousMonth() => _changeMonth(-1);

  Future<void> goToNextMonth() => _changeMonth(1);

  Future<void> _changeMonth(int monthDelta) async {
    final month = DateTime(state.month.year, state.month.month + monthDelta);
    emit(state.copyWith(month: month));
    emitPresentation(SleepHistoryShowLoading());
    await _loadMonth(month);
    emitPresentation(SleepHistoryHideLoading());
  }

  Future<void> changeTrendRange(TrendRange trendRange) async {
    emit(state.copyWith(trendRange: trendRange));
    emitPresentation(SleepHistoryShowLoading());
    await _loadTrend(trendRange);
    emitPresentation(SleepHistoryHideLoading());
  }

  Future<void> _loadMonth(DateTime month) async {
    final sleepResult = await _getSleepInRangeUseCase(from: month, to: DateTime(month.year, month.month + 1, 0));
    sleepResult.when(
      (error) => emitPresentation(SleepHistoryError(message: error.message)),
      (sleepByDate) => emit(state.copyWith(sleepInMonth: sleepByDate, isLoaded: true)),
    );
  }

  Future<void> _loadTrend(TrendRange trendRange) async {
    final to = _dateOnly(DateTime.now());
    final sleepResult = await _getSleepInRangeUseCase(
      from: to.subtract(Duration(days: trendRange.days - 1)),
      to: to,
    );
    sleepResult.when(
      (error) => emitPresentation(SleepHistoryError(message: error.message)),
      (sleepByDate) => emit(state.copyWith(sleepInTrendRange: sleepByDate)),
    );
  }
}
