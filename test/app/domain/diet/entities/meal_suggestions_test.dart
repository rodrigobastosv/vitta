import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';

void main() {
  test('fromMap reads every meal and its items', () {
    final suggestions = MealSuggestions.fromMap(const {
      'meals': [
        {
          'name': 'Chicken and rice',
          'summary': 'High protein',
          'items': [
            {'name': 'Grilled chicken', 'suggestedGrams': 150, 'caloriesPer100g': 165, 'proteinPer100g': 31, 'carbsPer100g': 0, 'fatPer100g': 3.6},
            {'name': 'White rice', 'suggestedGrams': 120, 'caloriesPer100g': 130, 'proteinPer100g': 2.7, 'carbsPer100g': 28, 'fatPer100g': 0.3},
          ],
        },
      ],
    });

    expect(suggestions.hasMeals, isTrue);
    expect(suggestions.meals.single.name, 'Chicken and rice');
    expect(suggestions.meals.single.items.map((item) => item.food.name), ['Grilled chicken', 'White rice']);
    expect(suggestions.meals.single.items.first.quantityGrams, 150);
  });

  // A suggestion is a catalog food nobody has typed in yet, which is the same
  // row a scanned item becomes - so it must land as custom, not as a source the
  // catalog has no policy for.
  test('a suggested item becomes a custom catalog food', () {
    final suggestions = MealSuggestions.fromMap(const {
      'meals': [
        {
          'name': 'Omelette',
          'items': [
            {'name': 'Egg', 'suggestedGrams': 100, 'caloriesPer100g': 155},
          ],
        },
      ],
    });

    expect(suggestions.meals.single.items.single.food.source, FoodSource.custom);
    expect(suggestions.meals.single.items.single.food.id, isNull);
  });

  test('an omitted macro reads as zero rather than failing the parse', () {
    final suggestions = MealSuggestions.fromMap(const {
      'meals': [
        {
          'name': 'Omelette',
          'items': [
            {'name': 'Egg', 'suggestedGrams': 100, 'caloriesPer100g': 155},
          ],
        },
      ],
    });

    final item = suggestions.meals.single.items.single;
    expect(item.food.proteinPer100g, 0);
    expect(item.food.fiberPer100g, 0);
    expect(suggestions.meals.single.summary, '');
  });

  test('an empty response is the found-nothing case, not an error', () {
    expect(MealSuggestions.fromMap(const {'meals': <dynamic>[]}).hasMeals, isFalse);
    expect(MealSuggestions.fromMap(const <String, dynamic>{}).hasMeals, isFalse);
  });

  // A meal totals through MacroTotals over FoodPortion, the same fold a logged
  // day and a recipe use - there is no second way to add macros in this app.
  test('a meal totals its items by their suggested amounts', () {
    final suggestions = MealSuggestions.fromMap(const {
      'meals': [
        {
          'name': 'Chicken and rice',
          'items': [
            {'name': 'Grilled chicken', 'suggestedGrams': 200, 'caloriesPer100g': 165, 'proteinPer100g': 31},
            {'name': 'White rice', 'suggestedGrams': 100, 'caloriesPer100g': 130, 'carbsPer100g': 28},
          ],
        },
      ],
    });

    final meal = suggestions.meals.single;
    expect(meal.totalCalories, closeTo(165 * 2 + 130, 0.001));
    expect(meal.totalProtein, closeTo(62, 0.001));
    expect(meal.totalCarbs, closeTo(28, 0.001));
    expect(meal.totalGrams, 300);
  });
}
