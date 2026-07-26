import 'package:vitta/app/core/error/premium_required_error.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/localization/app_localizations_lookup.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_suggested_meal_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/suggest_meals_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_entry.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_presentation_event.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_state.dart';

class MealSuggestionCubit extends PresentationCubit<MealSuggestionState, MealSuggestionPresentationEvent> {
  MealSuggestionCubit({
    required this._suggestMealsUseCase,
    required this._logSuggestedMealUseCase,
    required this._getDailyMacrosUseCase,
    required this._getMacroGoalsUseCase,
    required this._getAppSettingsUseCase,
    required this._loggedDate,
  }) : super(MealSuggestionState(mealType: MealType.forTime(DateTime.now())));

  final SuggestMealsUseCase _suggestMealsUseCase;
  final LogSuggestedMealUseCase _logSuggestedMealUseCase;
  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final GetMacroGoalsUseCase _getMacroGoalsUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final DateTime _loggedDate;

  @override
  void onInit() => loadDay();

  Future<void> loadDay() => withLoadingOverlay(
    () async {
      final dailyMacrosResult = await _getDailyMacrosUseCase(date: _loggedDate);
      dailyMacrosResult.when(
        (error) => emitPresentation(MealSuggestionError(message: error.message)),
        (dailyMacros) => emit(state.copyWith(dailyMacros: dailyMacros, goals: _getMacroGoalsUseCase(), isLoaded: true)),
      );
      if (!state.isLoaded) {
        emit(state.copyWith(goals: _getMacroGoalsUseCase(), isLoaded: true));
      }
    },
    showOverlay: state.isLoaded,
    showLoadingEvent: MealSuggestionShowLoading(),
    hideLoadingEvent: MealSuggestionHideLoading(),
  );

  Future<void> suggestMeals() async {
    emitPresentation(MealSuggestionThinking());
    final suggestionsResult = await _suggestMealsUseCase(
      mealType: state.mealType,
      loggedToday: state.dailyMacros,
      goals: state.goals,
      languageCode: localizationsFor(_getAppSettingsUseCase().locale).localeName,
    );
    emitPresentation(MealSuggestionHideLoading());
    suggestionsResult.when(_onSuggestFailed, _applySuggestions);
  }

  void _onSuggestFailed(VTError error) =>
      emitPresentation(error is PremiumRequiredError ? MealSuggestionPremiumRequired() : MealSuggestionError(message: error.message));

  void _applySuggestions(MealSuggestions suggestions) {
    if (!suggestions.hasMeals) {
      emit(state.copyWith(meals: const [], entriesByMeal: const [], hasRequested: true));
      emitPresentation(MealSuggestionFoundNothing());
      return;
    }
    Log.action('meal_suggestions_received', data: {'meal': state.mealType.wireValue, 'suggestions': suggestions.meals.length});
    emit(
      state.copyWith(
        hasRequested: true,
        selectedIndex: 0,
        meals: suggestions.meals,
        entriesByMeal: [
          for (final meal in suggestions.meals)
            [for (final item in meal.items) MealSuggestionEntry(item: item, gramsText: _formatGrams(item.quantityGrams))],
        ],
      ),
    );
  }

  // A suggestion is made for one meal, so keeping yesterday's lunch options on
  // screen after the user switches to dinner would offer to log a meal nobody
  // asked for. Changing the meal sends the page back to its request state.
  void mealTypeChanged(MealType mealType) =>
      emit(state.copyWith(mealType: mealType, meals: const [], entriesByMeal: const [], selectedIndex: 0, hasRequested: false));

  void selectMeal(int index) => emit(state.copyWith(selectedIndex: index));

  void gramsChanged({required int index, required String text}) =>
      _updateSelectedEntries((entry) => entry.copyWith(gramsText: text), at: index);

  void toggleIncluded({required int index}) => _updateSelectedEntries((entry) => entry.copyWith(isIncluded: !entry.isIncluded), at: index);

  void _updateSelectedEntries(MealSuggestionEntry Function(MealSuggestionEntry entry) update, {required int at}) => emit(
    state.copyWith(
      entriesByMeal: [
        for (final (mealIndex, entries) in state.entriesByMeal.indexed)
          if (mealIndex == state.selectedIndex)
            [
              for (final (entryIndex, entry) in entries.indexed)
                if (entryIndex == at) update(entry) else entry,
            ]
          else
            entries,
      ],
    ),
  );

  Future<void> logMeal() async {
    final includedEntries = state.includedEntries;
    if (!state.canLog) {
      emitPresentation(MealSuggestionIncomplete());
      return;
    }
    emitPresentation(MealSuggestionShowLoading());
    final loggedResult = await _logSuggestedMealUseCase(
      items: [for (final entry in includedEntries) SuggestedMealLogItem(food: entry.item.food, quantityGrams: entry.quantityGrams!)],
      loggedDate: _loggedDate,
      mealType: state.mealType,
    );
    emitPresentation(MealSuggestionHideLoading());
    loggedResult.when((error) => emitPresentation(MealSuggestionError(message: error.message)), (_) {
      Log.action('meal_logged_from_suggestion', data: {'meal': state.mealType.wireValue, 'items': includedEntries.length});
      emitPresentation(MealSuggestionLogged(mealType: state.mealType, itemCount: includedEntries.length));
    });
  }

  static String _formatGrams(double grams) => grams == grams.roundToDouble() ? grams.toStringAsFixed(0) : grams.toStringAsFixed(1);
}
