import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/meal_calorie_split.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';

DailyMacros buildDay(Map<MealType, double> caloriesByMeal) => DailyMacros(
  entries: [
    for (final MapEntry(key: mealType, value: calories) in caloriesByMeal.entries)
      FoodLogEntryFactory.build(
        food: FoodFactory.build(caloriesPer100g: calories),
        log: FoodLogFactory.build(mealType: mealType),
      ),
  ],
);

void main() {
  test('sums each meal across every day and shares them against the total', () {
    final split = MealCalorieSplit.fromLoggedDays([
      buildDay({MealType.breakfast: 500, MealType.dinner: 500}),
      buildDay({MealType.dinner: 1000}),
    ]);

    expect(split.totalCalories, 2000);
    expect(split.caloriesByMealType[MealType.breakfast], 500);
    expect(split.caloriesByMealType[MealType.dinner], 1500);
    expect(split.shareOf(MealType.dinner), 0.75);
    expect(split.shareOf(MealType.breakfast), 0.25);
  });

  test('averages a meal over the logged days, not over the meals it appeared in', () {
    final split = MealCalorieSplit.fromLoggedDays([
      buildDay({MealType.dinner: 1000}),
      buildDay({MealType.breakfast: 400}),
    ]);

    expect(split.loggedDayCount, 2);
    expect(split.dailyAverageOf(MealType.dinner), 500);
  });

  test('lists only the meals that carry calories, in meal order', () {
    final split = MealCalorieSplit.fromLoggedDays([
      buildDay({MealType.dinner: 600, MealType.breakfast: 300}),
    ]);

    expect(split.presentMealTypes, [MealType.breakfast, MealType.dinner]);
  });

  test('a day with no entries neither counts nor divides', () {
    final split = MealCalorieSplit.fromLoggedDays([
      buildDay({MealType.lunch: 800}),
      const DailyMacros(entries: []),
    ]);

    expect(split.loggedDayCount, 1);
    expect(split.dailyAverageOf(MealType.lunch), 800);
  });

  test('has no data and no shares when nothing was logged', () {
    final split = MealCalorieSplit.fromLoggedDays(const []);

    expect(split.hasData, isFalse);
    expect(split.presentMealTypes, isEmpty);
    expect(split.shareOf(MealType.lunch), 0);
    expect(split.dailyAverageOf(MealType.lunch), 0);
  });
}
