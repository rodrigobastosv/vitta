import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';

DailyMacros _dayWith({required double calories, required double protein, required double carbs, required double fat, required double fiber}) => DailyMacros(
  entries: [
    FoodLogEntryFactory.build(
      food: FoodFactory.build(caloriesPer100g: calories, proteinPer100g: protein, carbsPer100g: carbs, fatPer100g: fat, fiberPer100g: fiber),
      log: FoodLogFactory.build(),
    ),
  ],
);

void main() {
  test('sums macros across all entries', () {
    final dailyMacros = DailyMacros(
      entries: [
        FoodLogEntryFactory.build(
          food: FoodFactory.build(caloriesPer100g: 100, proteinPer100g: 10, carbsPer100g: 5, fatPer100g: 2, fiberPer100g: 3),
          log: FoodLogFactory.build(),
        ),
        FoodLogEntryFactory.build(
          food: FoodFactory.build(caloriesPer100g: 200, proteinPer100g: 20, carbsPer100g: 10, fatPer100g: 4, fiberPer100g: 6),
          log: FoodLogFactory.build(quantityGrams: 50),
        ),
      ],
    );

    expect(dailyMacros.totalCalories, 200);
    expect(dailyMacros.totalProtein, 20);
    expect(dailyMacros.totalCarbs, 10);
    expect(dailyMacros.totalFat, 4);
    expect(dailyMacros.totalFiber, 6);
  });

  test('totals are zero with no entries', () {
    const dailyMacros = DailyMacros(entries: []);

    expect(dailyMacros.totalCalories, 0);
    expect(dailyMacros.totalProtein, 0);
    expect(dailyMacros.totalCarbs, 0);
    expect(dailyMacros.totalFat, 0);
    expect(dailyMacros.totalFiber, 0);
  });

  test('sums micronutrients across entries, keeping only present nutrients', () {
    final dailyMacros = DailyMacros(
      entries: [
        FoodLogEntryFactory.build(
          food: FoodFactory.build(micronutrientsPer100g: const {Nutrient.vitaminC: 0.01, Nutrient.iron: 0.002}),
          log: FoodLogFactory.build(),
        ),
        FoodLogEntryFactory.build(
          food: FoodFactory.build(micronutrientsPer100g: const {Nutrient.vitaminC: 0.005}),
          log: FoodLogFactory.build(quantityGrams: 200),
        ),
      ],
    );

    expect(dailyMacros.micronutrientTotals, {Nutrient.vitaminC: 0.02, Nutrient.iron: 0.002});
  });

  test('groups entries into meal sections in meal-type order, skipping empty meals', () {
    final dailyMacros = DailyMacros(
      entries: [
        FoodLogEntryFactory.build(
          log: FoodLogFactory.build(id: 'dinner-1', mealType: .dinner),
        ),
        FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'breakfast-1')),
        FoodLogEntryFactory.build(
          log: FoodLogFactory.build(id: 'dinner-2', mealType: .dinner),
        ),
      ],
    );

    final meals = dailyMacros.meals;

    expect(meals.map((meal) => meal.mealType), [MealType.breakfast, MealType.dinner]);
    expect(meals.first.entries.map((entry) => entry.log.id), ['breakfast-1']);
    expect(meals.last.entries.map((entry) => entry.log.id), ['dinner-1', 'dinner-2']);
  });

  test('a meal section sums macros for its own entries only', () {
    final dailyMacros = DailyMacros(
      entries: [
        FoodLogEntryFactory.build(
          food: FoodFactory.build(caloriesPer100g: 100, proteinPer100g: 10, carbsPer100g: 5, fatPer100g: 2, fiberPer100g: 3),
          log: FoodLogFactory.build(),
        ),
        FoodLogEntryFactory.build(
          food: FoodFactory.build(caloriesPer100g: 200, proteinPer100g: 20, carbsPer100g: 10, fatPer100g: 4, fiberPer100g: 6),
          log: FoodLogFactory.build(mealType: .lunch),
        ),
      ],
    );

    final breakfast = dailyMacros.meals.first;

    expect(breakfast.mealType, MealType.breakfast);
    expect(breakfast.totalCalories, 100);
    expect(breakfast.totalProtein, 10);
    expect(breakfast.totalCarbs, 5);
    expect(breakfast.totalFat, 2);
    expect(breakfast.totalFiber, 3);
  });

  test('adherenceTo is met when calories sit inside the goal band, ignoring other macros', () {
    const goals = MacroGoals.defaultGoals;
    final dailyMacros = _dayWith(
      calories: goals.calorieGoal,
      protein: goals.proteinGoalGrams * 3,
      carbs: goals.carbsGoalGrams * 3,
      fat: goals.fatGoalGrams * 3,
      fiber: goals.fiberGoalGrams * 3,
    );

    expect(dailyMacros.adherenceTo(goals), GoalAdherence.met);
  });

  test('adherenceTo is close when calories are moderately over the goal', () {
    const goals = MacroGoals.defaultGoals;
    final dailyMacros = _dayWith(
      calories: goals.calorieGoal * 1.2,
      protein: goals.proteinGoalGrams,
      carbs: goals.carbsGoalGrams,
      fat: goals.fatGoalGrams,
      fiber: goals.fiberGoalGrams,
    );

    expect(dailyMacros.adherenceTo(goals), GoalAdherence.close);
  });

  test('adherenceTo is off when calories are far from the goal', () {
    const goals = MacroGoals.defaultGoals;
    final dailyMacros = _dayWith(
      calories: goals.calorieGoal * 2,
      protein: goals.proteinGoalGrams,
      carbs: goals.carbsGoalGrams,
      fat: goals.fatGoalGrams,
      fiber: goals.fiberGoalGrams,
    );

    expect(dailyMacros.adherenceTo(goals), GoalAdherence.off);
  });
}
