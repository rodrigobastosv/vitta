import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

import 'food_factory.dart';

abstract class RecipeIngredientFactory {
  static RecipeIngredient build({String? id = 'ingredient-1', Food? food, double quantityGrams = 100}) =>
      RecipeIngredient(id: id, food: food ?? FoodFactory.build(), quantityGrams: quantityGrams);
}
