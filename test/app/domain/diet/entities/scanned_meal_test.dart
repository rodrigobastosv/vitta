import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';

void main() {
  test('fromMap parses every item and defaults missing numbers to 0', () {
    final meal = ScannedMeal.fromMap(const {
      'items': [
        {
          'name': 'Grilled chicken',
          'estimatedGrams': 150,
          'caloriesPer100g': 165,
          'proteinPer100g': 31,
          'carbsPer100g': 0,
          'fatPer100g': 3.6,
          'fiberPer100g': 0,
        },
        {'name': 'White rice', 'estimatedGrams': 200, 'caloriesPer100g': 130},
      ],
    });

    expect(meal.hasItems, isTrue);
    expect(meal.items, hasLength(2));
    expect(meal.items.first.name, 'Grilled chicken');
    expect(meal.items.first.estimatedGrams, 150);
    expect(meal.items.last.proteinPer100g, 0);
    expect(meal.items.last.caloriesPer100g, 130);
  });

  test('fromMap yields no items when the list is absent', () {
    final meal = ScannedMeal.fromMap(const {});

    expect(meal.hasItems, isFalse);
    expect(meal.items, isEmpty);
  });

  test('toFood maps an item into a custom food carrying its per-100g macros', () {
    const item = ScannedMealItem(
      name: 'Grilled chicken',
      estimatedGrams: 150,
      caloriesPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
      fiberPer100g: 1,
    );

    final food = item.toFood();

    expect(food.id, isNull);
    expect(food.name, 'Grilled chicken');
    expect(food.source, FoodSource.custom);
    expect(food.caloriesPer100g, 165);
    expect(food.proteinPer100g, 31);
    expect(food.fiberPer100g, 1);
  });
}
