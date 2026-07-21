import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_in_range_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_state.dart';

class WaterHistoryCubit extends PresentationCubit<WaterHistoryState, WaterHistoryPresentationEvent> {
  WaterHistoryCubit({required this._getWaterInRangeUseCase, required this._getWaterGoalUseCase})
    : super(WaterHistoryState(isLoaded: false, month: _monthOf(DateTime.now()), dailyGoalMl: WaterLocalDataSource.defaultDailyGoalMl));

  final GetWaterInRangeUseCase _getWaterInRangeUseCase;
  final GetWaterGoalUseCase _getWaterGoalUseCase;

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
    emitPresentation(WaterHistoryShowLoading());
    emit(state.copyWith(dailyGoalMl: _getWaterGoalUseCase()));
    await _loadMonth(state.month);
    await _loadTrend(state.trendRange);
    emitPresentation(WaterHistoryHideLoading());
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> goToPreviousMonth() => _changeMonth(-1);

  Future<void> goToNextMonth() => _changeMonth(1);

  Future<void> _changeMonth(int monthDelta) async {
    final month = DateTime(state.month.year, state.month.month + monthDelta);
    emit(state.copyWith(month: month));
    emitPresentation(WaterHistoryShowLoading());
    await _loadMonth(month);
    emitPresentation(WaterHistoryHideLoading());
  }

  Future<void> changeTrendRange(TrendRange trendRange) async {
    emit(state.copyWith(trendRange: trendRange));
    emitPresentation(WaterHistoryShowLoading());
    await _loadTrend(trendRange);
    emitPresentation(WaterHistoryHideLoading());
  }

  Future<void> _loadMonth(DateTime month) async {
    final waterResult = await _getWaterInRangeUseCase(from: month, to: DateTime(month.year, month.month + 1, 0));
    waterResult.when(
      (error) => emitPresentation(WaterHistoryError(message: error.message)),
      (waterByDate) => emit(state.copyWith(waterInMonth: waterByDate, isLoaded: true)),
    );
  }

  Future<void> _loadTrend(TrendRange trendRange) async {
    final to = _dateOnly(DateTime.now());
    final waterResult = await _getWaterInRangeUseCase(
      from: to.subtract(Duration(days: trendRange.days - 1)),
      to: to,
    );
    waterResult.when(
      (error) => emitPresentation(WaterHistoryError(message: error.message)),
      (waterByDate) => emit(state.copyWith(waterInTrendRange: waterByDate)),
    );
  }
}
