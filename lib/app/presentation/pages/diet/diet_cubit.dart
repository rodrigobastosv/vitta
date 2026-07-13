import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_logged_dates_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

class DietCubit extends PresentationCubit<DietState, DietPresentationEvent> {
  DietCubit({
    required this._getDailyMacrosUseCase,
    required this._deleteFoodLogUseCase,
    required this._getMacroGoalsUseCase,
    required this._getLoggedDatesUseCase,
  }) : super(
         DietState(
           date: _dateOnly(DateTime.now()),
           dailyMacros: const DailyMacros(entries: []),
           macroGoals: MacroGoals.defaultGoals,
         ),
       );

  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final DeleteFoodLogUseCase _deleteFoodLogUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;
  final GetLoggedDatesUseCase _getLoggedDatesUseCase;

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  DateTime get _today => _dateOnly(DateTime.now());

  bool get isViewingToday => state.date == _today;

  @override
  void onInit() => loadToday();

  Future<void> loadToday() => _loadDate(_today);

  Future<void> refresh() => _loadDate(state.date);

  Future<void> goToPreviousDay() => _goToDate(state.date.subtract(const Duration(days: 1)));

  Future<void> goToNextDay() => _goToDate(state.date.add(const Duration(days: 1)));

  Future<void> goToDate(DateTime date) => _goToDate(_dateOnly(date));

  Future<void> _goToDate(DateTime date) {
    emit(state.copyWith(date: date));
    return _loadDate(date);
  }

  Future<void> _loadDate(DateTime date) async {
    emitPresentation(DietShowLoading());
    final macroGoals = _getMacroGoalsUseCase();
    final dailyMacrosResult = await _getDailyMacrosUseCase(date: date);
    emitPresentation(DietHideLoading());
    dailyMacrosResult.when(
      (error) => emitPresentation(DietError(message: error.message, date: date)),
      (value) => emit(state.copyWith(date: date, dailyMacros: value, macroGoals: macroGoals)),
    );
  }

  Future<void> loadLoggedDatesForMonth(DateTime month) async {
    final datesResult = await _getLoggedDatesUseCase(from: DateTime(month.year, month.month), to: DateTime(month.year, month.month + 1, 0));
    datesResult.when((_) => null, (dates) => emit(state.copyWith(loggedDatesInMonth: dates)));
  }

  Future<void> deleteLog({required String logId}) async {
    final deletedResult = await _deleteFoodLogUseCase(logId: logId);
    deletedResult.when((error) => emitPresentation(DietError(message: error.message, date: state.date)), (_) => _loadDate(state.date));
  }
}
