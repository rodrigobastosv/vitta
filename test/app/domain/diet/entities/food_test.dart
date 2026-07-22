import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_category.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

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
      'image_url': 'https://example.com/banana.jpg',
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
        imageUrl: 'https://example.com/banana.jpg',
      ),
    );
  });

  test('fromMap parses a barcode-less generic whole food with its category', () {
    final food = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Arroz branco cozido',
      'brand': null,
      'barcode': null,
      'source': 'generic',
      'calories_per_100g': 130,
      'protein_per_100g': 2.7,
      'carbs_per_100g': 28,
      'fat_per_100g': 0.3,
      'fiber_per_100g': 0.4,
      'category': 'grain',
    });

    expect(food.source, FoodSource.generic);
    expect(food.barcode, isNull);
    expect(food.category, FoodCategory.grain);
  });

  test('fromMap leaves category null when the column is missing or unknown', () {
    final noColumn = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Banana',
      'source': 'open_food_facts',
      'calories_per_100g': 89,
      'protein_per_100g': 1.1,
      'carbs_per_100g': 22.8,
      'fat_per_100g': 0.3,
    });
    final unknown = Food.fromMap(const {
      'id': 'food-2',
      'name': 'Something',
      'source': 'open_food_facts',
      'calories_per_100g': 89,
      'protein_per_100g': 1.1,
      'carbs_per_100g': 22.8,
      'fat_per_100g': 0.3,
      'category': 'restaurant_foods',
    });

    expect(noColumn.category, isNull);
    expect(unknown.category, isNull);
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
    expect(food.imageUrl, isNull);
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

  test('fromMap parses known micronutrients and ignores unknown keys', () {
    final food = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Banana',
      'brand': null,
      'barcode': null,
      'source': 'open_food_facts',
      'calories_per_100g': 89,
      'protein_per_100g': 1.1,
      'carbs_per_100g': 22.8,
      'fat_per_100g': 0.3,
      'micronutrients': {'vitamin_c': 0.0087, 'potassium': 0.358, 'made_up_nutrient': 1.0},
    });

    expect(food.micronutrientsPer100g, {Nutrient.vitaminC: 0.0087, Nutrient.potassium: 0.358});
  });

  test('fromMap defaults micronutrients to empty when the column is missing', () {
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

    expect(food.micronutrientsPer100g, isEmpty);
  });

  test('fromMap parses the weight of one unit for a countable food', () {
    final food = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Ovo',
      'brand': null,
      'barcode': null,
      'source': 'open_food_facts',
      'calories_per_100g': 155,
      'protein_per_100g': 13,
      'carbs_per_100g': 1.1,
      'fat_per_100g': 11,
      'grams_per_unit': 50,
    });

    expect(food.gramsPerUnit, 50);
    expect(food.isCountable, isTrue);
  });

  test('fromMap leaves a food nobody has asked the converter about uncountable', () {
    final food = Food.fromMap(const {
      'id': 'food-1',
      'name': 'Arroz',
      'brand': null,
      'barcode': null,
      'source': 'open_food_facts',
      'calories_per_100g': 130,
      'protein_per_100g': 2.7,
      'carbs_per_100g': 28,
      'fat_per_100g': 0.3,
    });

    expect(food.gramsPerUnit, isNull);
    expect(food.isCountable, isFalse);
  });
}
