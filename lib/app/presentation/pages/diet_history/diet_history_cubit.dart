import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macros_in_range_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_state.dart';

class DietHistoryCubit extends PresentationCubit<DietHistoryState, DietHistoryPresentationEvent> {
  DietHistoryCubit({required this._getMacrosInRangeUseCase, required this._getMacroGoalsUseCase})
    : super(DietHistoryState(isLoaded: false, month: _monthOf(DateTime.now()), macroGoals: MacroGoals.defaultGoals));

  final GetMacrosInRangeUseCase _getMacrosInRangeUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool get isViewingCurrentMonth => state.month == _monthOf(DateTime.now());

  @override
  void onInit() => refresh();

  Future<void> refresh() async {
    emitPresentation(DietHistoryShowLoading());
    emit(state.copyWith(macroGoals: _getMacroGoalsUseCase()));
    await _loadMonth(state.month);
    await _loadTrend(state.trendRange);
    emitPresentation(DietHistoryHideLoading());
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> goToPreviousMonth() => _changeMonth(-1);

  Future<void> goToNextMonth() => _changeMonth(1);

  Future<void> _changeMonth(int monthDelta) async {
    final month = DateTime(state.month.year, state.month.month + monthDelta);
    emit(state.copyWith(month: month));
    emitPresentation(DietHistoryShowLoading());
    await _loadMonth(month);
    emitPresentation(DietHistoryHideLoading());
  }

  Future<void> changeTrendRange(TrendRange trendRange) async {
    emit(state.copyWith(trendRange: trendRange));
    emitPresentation(DietHistoryShowLoading());
    await _loadTrend(trendRange);
    emitPresentation(DietHistoryHideLoading());
  }

  Future<void> _loadMonth(DateTime month) async {
    final macrosResult = await _getMacrosInRangeUseCase(from: month, to: DateTime(month.year, month.month + 1, 0));
    macrosResult.when(
      (error) => emitPresentation(DietHistoryError(message: error.message)),
      (macrosByDate) => emit(state.copyWith(macrosInMonth: macrosByDate, isLoaded: true)),
    );
  }

  Future<void> _loadTrend(TrendRange trendRange) async {
    final to = _dateOnly(DateTime.now());
    final macrosResult = await _getMacrosInRangeUseCase(
      from: to.subtract(Duration(days: trendRange.days - 1)),
      to: to,
    );
    macrosResult.when(
      (error) => emitPresentation(DietHistoryError(message: error.message)),
      (macrosByDate) => emit(state.copyWith(macrosInTrendRange: macrosByDate)),
    );
  }
}
