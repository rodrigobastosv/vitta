import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_gap.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class SuggestMealsUseCase {
  SuggestMealsUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, MealSuggestions>> call({
    required MealType mealType,
    required DailyMacros loggedToday,
    required MacroGoals goals,
    required String languageCode,
  }) => _dietRepository.suggestMeals(
    mealType: mealType,
    gap: MacroGap.between(consumed: loggedToday, goals: goals),
    goals: goals,
    loggedToday: loggedToday,
    languageCode: languageCode,
  );
}
