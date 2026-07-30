import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';

// The five figures a day is judged on. Deliberately not CustomFoodNutrient,
// which names the same five: that one is a *field on a form* and pairs each case
// with a colour, a unit and a ScannedNutritionFacts reading, where this one is a
// *nutrient with a daily goal* and stays out of Flutter. Same cases, different
// jobs - the split Nutrient and CustomFoodNutrient already make.
enum MacroNutrient {
  calories,
  protein,
  carbs,
  fat,
  fiber;

  double consumedIn(MacroTotals totals) => switch (this) {
    .calories => totals.totalCalories,
    .protein => totals.totalProtein,
    .carbs => totals.totalCarbs,
    .fat => totals.totalFat,
    .fiber => totals.totalFiber,
  };

  double goalIn(MacroGoals goals) => switch (this) {
    .calories => goals.calorieGoal,
    .protein => goals.proteinGoalGrams,
    .carbs => goals.carbsGoalGrams,
    .fat => goals.fatGoalGrams,
    .fiber => goals.fiberGoalGrams,
  };

  // What each nutrient is worth in the day's score, paired with its case the way
  // ExerciseCategory pairs a MET value. Calories carry the most because they are
  // the headline every other surface already judges a day by; fibre the least,
  // because its goal is the softest of the five.
  double get scoreWeight => switch (this) {
    .calories => 0.4,
    .protein => 0.2,
    .carbs => 0.15,
    .fat => 0.15,
    .fiber => 0.1,
  };
}
