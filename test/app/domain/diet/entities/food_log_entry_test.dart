import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';

void main() {
  test('scales macros by quantity relative to 100g', () {
    final entry = FoodLogEntryFactory.build(
      food: FoodFactory.build(caloriesPer100g: 200, proteinPer100g: 20, carbsPer100g: 10, fatPer100g: 5),
      log: FoodLogFactory.build(quantityGrams: 150),
    );

    expect(entry.calories, 300);
    expect(entry.protein, 30);
    expect(entry.carbs, 15);
    expect(entry.fat, 7.5);
  });

  test('fromMap parses a joined food_logs/foods row', () {
    final entry = FoodLogEntry.fromMap(const {
      'id': 'log-1',
      'food_id': 'food-1',
      'logged_date': '2026-07-11',
      'meal_type': 'lunch',
      'quantity_grams': 150,
      'foods': {
        'id': 'food-1',
        'name': 'Banana',
        'brand': null,
        'barcode': null,
        'source': 'open_food_facts',
        'calories_per_100g': 89,
        'protein_per_100g': 1.1,
        'carbs_per_100g': 22.8,
        'fat_per_100g': 0.3,
      },
    });

    expect(
      entry,
      FoodLogEntry(
        log: FoodLog(id: 'log-1', foodId: 'food-1', loggedDate: DateTime(2026, 7, 11), mealType: MealType.lunch, quantityGrams: 150),
        food: const Food(
          id: 'food-1',
          name: 'Banana',
          source: FoodSource.openFoodFacts,
          caloriesPer100g: 89,
          proteinPer100g: 1.1,
          carbsPer100g: 22.8,
          fatPer100g: 0.3,
        ),
      ),
    );
  });
}
