import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_plausibility.dart';

void main() {
  group('isPlausible', () {
    test('rejects figures above the physical ceiling of pure fat', () {
      expect(FoodPlausibility.isPlausible(caloriesPer100g: 22000), isFalse);
      expect(FoodPlausibility.isPlausible(caloriesPer100g: 901), isFalse);
    });

    test('accepts the densest real foods, which sit just under it', () {
      expect(FoodPlausibility.isPlausible(caloriesPer100g: 900), isTrue);
      expect(FoodPlausibility.isPlausible(caloriesPer100g: 884), isTrue);
    });

    // The rule that nearly deleted 1,089 rows. Salt, bottled water and black
    // coffee are all-zero AND real, so carrying no nutrition must never make a
    // food implausible - only physics does.
    test('accepts a food that carries no nutrition at all', () {
      expect(FoodPlausibility.isPlausible(caloriesPer100g: 0), isTrue);
    });
  });

  group('statesNoNutrition', () {
    test('is true only when every macro and the calories are zero', () {
      expect(
        FoodPlausibility.statesNoNutrition(caloriesPer100g: 0, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 0),
        isTrue,
      );
    });

    test('is false when anything at all was stated', () {
      expect(
        FoodPlausibility.statesNoNutrition(caloriesPer100g: 0, proteinPer100g: 0.5, carbsPer100g: 0, fatPer100g: 0),
        isFalse,
      );
      expect(
        FoodPlausibility.statesNoNutrition(caloriesPer100g: 61, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 0),
        isFalse,
      );
    });

    test('is a question for a human, so it never implies implausible', () {
      const water = (calories: 0.0, protein: 0.0, carbs: 0.0, fat: 0.0);
      expect(
        FoodPlausibility.statesNoNutrition(
          caloriesPer100g: water.calories,
          proteinPer100g: water.protein,
          carbsPer100g: water.carbs,
          fatPer100g: water.fat,
        ),
        isTrue,
      );
      expect(FoodPlausibility.isPlausible(caloriesPer100g: water.calories), isTrue);
    });
  });
}
