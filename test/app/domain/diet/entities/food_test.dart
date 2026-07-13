import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

void main() {
  test('fromMap parses a Supabase foods row', () {
    final food = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Banana',
      'brand': 'Chiquita',
      'barcode': '1234567890',
      'source': 'open_food_facts',
      'calories_per_100g': 89,
      'protein_per_100g': 1.1,
      'carbs_per_100g': 22.8,
      'fat_per_100g': 0.3,
      'fiber_per_100g': 2.6,
    });

    expect(
      food,
      const Food(
        id: 'food-1',
        name: 'Banana',
        brand: 'Chiquita',
        barcode: '1234567890',
        source: FoodSource.openFoodFacts,
        caloriesPer100g: 89,
        proteinPer100g: 1.1,
        carbsPer100g: 22.8,
        fatPer100g: 0.3,
        fiberPer100g: 2.6,
      ),
    );
  });

  test('fromMap handles null brand and barcode', () {
    final food = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Custom food',
      'brand': null,
      'barcode': null,
      'source': 'custom',
      'calories_per_100g': 100,
      'protein_per_100g': 10,
      'carbs_per_100g': 10,
      'fat_per_100g': 10,
      'fiber_per_100g': 5,
    });

    expect(food.brand, isNull);
    expect(food.barcode, isNull);
  });

  test('fromMap defaults fiber to 0 when the column is missing', () {
    final food = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Legacy food',
      'brand': null,
      'barcode': null,
      'source': 'custom',
      'calories_per_100g': 100,
      'protein_per_100g': 10,
      'carbs_per_100g': 10,
      'fat_per_100g': 10,
    });

    expect(food.fiberPer100g, 0);
  });
}
