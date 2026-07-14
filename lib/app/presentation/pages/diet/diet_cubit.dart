import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_monthly_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/update_food_log_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

class DietCubit extends PresentationCubit<DietState, DietPresentationEvent> {
  DietCubit({
    required this._getDailyMacrosUseCase,
    required this._deleteFoodLogUseCase,
    required this._updateFoodLogUseCase,
    required this._getMacroGoalsUseCase,
    required this._getMonthlyMacrosUseCase,
    required this._getAppSettingsUseCase,
  }) : super(
         DietState(
           date: _dateOnly(DateTime.now()),
           dailyMacros: const DailyMacros(entries: []),
           macroGoals: MacroGoals.defaultGoals,
         ),
       );

  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final DeleteFoodLogUseCase _deleteFoodLogUseCase;
  final UpdateFoodLogUseCase _updateFoodLogUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;
  final GetMonthlyMacrosUseCase _getMonthlyMacrosUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

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

  Future<void> loadMonthMacros(DateTime month) async {
    final monthlyMacrosResult = await _getMonthlyMacrosUseCase(
      from: DateTime(month.year, month.month),
      to: DateTime(month.year, month.month + 1, 0),
    );
    monthlyMacrosResult.when((_) => null, (macrosByDate) => emit(state.copyWith(loggedMacrosInMonth: macrosByDate)));
  }

  Future<Result<VTError, FoodLog>> updateLog({
    required String logId,
    required MealType mealType,
    required double quantityGrams,
  }) async {
    final updatedResult = await _updateFoodLogUseCase(logId: logId, mealType: mealType, quantityGrams: quantityGrams);
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
