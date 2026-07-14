import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/recipe_ingredient_factory.dart';

void main() {
  test('sums grams, calories and macros across its ingredients', () {
    final draft = RecipeDraft(
      name: 'Lasagna',
      ingredients: [
        RecipeIngredientFactory.build(
          food: FoodFactory.build(caloriesPer100g: 100, proteinPer100g: 10, carbsPer100g: 20, fatPer100g: 5, fiberPer100g: 1),
          quantityGrams: 200,
        ),
        RecipeIngredientFactory.build(
          food: FoodFactory.build(caloriesPer100g: 50, proteinPer100g: 4, carbsPer100g: 6, fatPer100g: 2, fiberPer100g: 3),
        ),
      ],
    );

    expect(draft.totalGrams, 300);
    expect(draft.totalCalories, 250);
    expect(draft.totalProtein, 24);
    expect(draft.totalCarbs, 46);
    expect(draft.totalFat, 12);
    expect(draft.totalFiber, 5);
  });

  test('turns into a food whose macros are the per-100g roll-up of the whole recipe', () {
    final draft = RecipeDraft(
      name: '  Lasagna  ',
      ingredients: [
        RecipeIngredientFactory.build(
          food: FoodFactory.build(caloriesPer100g: 100, proteinPer100g: 10, carbsPer100g: 20, fatPer100g: 5, fiberPer100g: 1),
          quantityGrams: 200,
        ),
      ],
    );

    final food = draft.toFood();

    expect(food.name, 'Lasagna');
    expect(food.source, FoodSource.recipe);
    expect(food.id, isNull);
    expect(food.caloriesPer100g, 100);
    expect(food.proteinPer100g, 10);
  });

  test('scales the roll-up when the recipe weighs more than its per-100g basis', () {
    final draft = RecipeDraft(
      name: 'Shake',
      ingredients: [
        RecipeIngredientFactory.build(food: FoodFactory.build(caloriesPer100g: 400), quantityGrams: 50),
        RecipeIngredientFactory.build(food: FoodFactory.build(caloriesPer100g: 0), quantityGrams: 150),
      ],
    );

    expect(draft.totalCalories, 200);
    expect(draft.totalGrams, 200);
    expect(draft.toFood().caloriesPer100g, 100);
  });

  test('carries micronutrients through the roll-up', () {
    final draft = RecipeDraft(
      name: 'Salad',
      ingredients: [
        RecipeIngredientFactory.build(
          food: FoodFactory.build(micronutrientsPer100g: const {Nutrient.iron: 0.01}),
          quantityGrams: 200,
        ),
      ],
    );

    expect(draft.micronutrientTotals[Nutrient.iron], closeTo(0.02, 0.0001));
    expect(draft.toFood().micronutrientsPer100g[Nutrient.iron], closeTo(0.01, 0.0001));
  });

  test('is incomplete without a name or without ingredients', () {
    expect(const RecipeDraft().isComplete, isFalse);
    expect(RecipeDraft(name: 'Lasagna', ingredients: [RecipeIngredientFactory.build()]).isComplete, isTrue);
    expect(const RecipeDraft(name: '   ').isComplete, isFalse);
    expect(RecipeDraft(ingredients: [RecipeIngredientFactory.build()]).isComplete, isFalse);
  });

  test('an empty draft has no macros to divide by zero grams', () {
    const draft = RecipeDraft(name: 'Empty');

    expect(draft.totalGrams, 0);
    expect(draft.per100g(draft.totalCalories), 0);
    expect(draft.toFood().caloriesPer100g, 0);
  });
}
