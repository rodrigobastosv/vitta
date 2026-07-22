import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_section.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/use_cases/copy_food_logs_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macros_in_range_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_presentation_event.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_state.dart';

class CopyMealsCubit extends PresentationCubit<CopyMealsState, CopyMealsPresentationEvent> {
  CopyMealsCubit({
    required this._getMacrosInRangeUseCase,
    required this._getMacroGoalsUseCase,
    required this._copyFoodLogsUseCase,
    required DateTime targetDate,
  }) : super(CopyMealsState(targetDate: targetDate, month: _monthOf(targetDate), macroGoals: MacroGoals.defaultGoals));

  final GetMacrosInRangeUseCase _getMacrosInRangeUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;
  final CopyFoodLogsUseCase _copyFoodLogsUseCase;

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  bool get isViewingCurrentMonth => state.month == _monthOf(DateTime.now());

  @override
  void onInit() => refresh();

  Future<void> refresh() async {
    emitPresentation(CopyMealsShowLoading());
    emit(state.copyWith(macroGoals: _getMacroGoalsUseCase()));
    await _loadMonth(state.month);
    emitPresentation(CopyMealsHideLoading());
  }

  Future<void> goToPreviousMonth() => _changeMonth(-1);

  Future<void> goToNextMonth() => _changeMonth(1);

  Future<void> _changeMonth(int monthDelta) async {
    final month = DateTime(state.month.year, state.month.month + monthDelta);
    emit(state.copyWith(month: month));
    emitPresentation(CopyMealsShowLoading());
    await _loadMonth(month);
    emitPresentation(CopyMealsHideLoading());
  }

  Future<void> _loadMonth(DateTime month) async {
    final macrosResult = await _getMacrosInRangeUseCase(from: month, to: DateTime(month.year, month.month + 1, 0));
    macrosResult.when(
      (error) => emitPresentation(CopyMealsError(message: error.message)),
      (macrosByDate) => emit(state.copyWith(macrosByDate: {...state.macrosByDate, ...macrosByDate})),
    );
  }

  void selectSourceDate(DateTime date) => emit(
    state.copyWith(sourceDate: date, selectedMealTypes: {for (final section in state.macrosByDate[date]?.meals ?? const <MealSection>[]) section.mealType}),
  );

  void toggleMeal(MealType mealType) {
    final selectedMealTypes = {...state.selectedMealTypes};
    if (!selectedMealTypes.remove(mealType)) {
      selectedMealTypes.add(mealType);
    }
    emit(state.copyWith(selectedMealTypes: selectedMealTypes));
  }

  Future<void> copy() async {
    final entries = state.entriesToCopy;
    if (entries.isEmpty) {
      return;
    }
    emitPresentation(CopyMealsShowLoading());
    final copiedResult = await _copyFoodLogsUseCase(entries: entries, targetDate: state.targetDate);
    emitPresentation(CopyMealsHideLoading());
    copiedResult.when((error) => emitPresentation(CopyMealsError(message: error.message)), (_) {
      Log.action(.mealsCopied, data: {'meals': state.selectedMealTypes.length, 'entries': entries.length});
      emitPresentation(MealsCopied(mealCount: state.selectedMealTypes.length));
    });
  }
}
