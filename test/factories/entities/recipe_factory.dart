import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

import 'food_factory.dart';
import 'recipe_ingredient_factory.dart';

abstract class RecipeFactory {
  static Recipe build({String id = 'recipe-1', Food? food, List<RecipeIngredient>? ingredients}) => Recipe(
    id: id,
    food: food ?? FoodFactory.build(name: 'Lasagna'),
    ingredients: ingredients ?? [RecipeIngredientFactory.build()],
  );
}
