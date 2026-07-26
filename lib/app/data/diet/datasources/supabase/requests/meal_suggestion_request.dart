import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_gap.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class MealSuggestionRequest {
  MealSuggestionRequest({
    required this.mealType,
    required this.gap,
    required this.goals,
    required this.loggedToday,
    required this.languageCode,
  });

  final MealType mealType;
  final MacroGap gap;
  final MacroGoals goals;
  final DailyMacros loggedToday;
  final String languageCode;

  // The already-logged foods ride along beside the gap because the gap alone
  // cannot stop the model suggesting the chicken and rice the user already ate
  // today. Names and amounts only - a food's identity is what makes a repeat
  // recognisable, and nothing else about the log is the model's business.
  Map<String, dynamic> toJson() => {
    'mealType': mealType.wireValue,
    'languageCode': languageCode,
    'goal': _macros(
      calories: goals.calorieGoal,
      protein: goals.proteinGoalGrams,
      carbs: goals.carbsGoalGrams,
      fat: goals.fatGoalGrams,
      fiber: goals.fiberGoalGrams,
    ),
    'consumed': _macros(
      calories: loggedToday.totalCalories,
      protein: loggedToday.totalProtein,
      carbs: loggedToday.totalCarbs,
      fat: loggedToday.totalFat,
      fiber: loggedToday.totalFiber,
    ),
    'remaining': _macros(calories: gap.calories, protein: gap.protein, carbs: gap.carbs, fat: gap.fat, fiber: gap.fiber),
    'loggedFoods': [
      for (final entry in loggedToday.entries)
        {'name': entry.food.name, 'mealType': entry.log.mealType.wireValue, 'quantityGrams': _rounded(entry.quantityGrams)},
    ],
  };

  Map<String, dynamic> _macros({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
  }) => {
    'calories': _rounded(calories),
    'protein': _rounded(protein),
    'carbs': _rounded(carbs),
    'fat': _rounded(fat),
    'fiber': _rounded(fiber),
  };

  double _rounded(double value) => double.parse(value.toStringAsFixed(1));
}
