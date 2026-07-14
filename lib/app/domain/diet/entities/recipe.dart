import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_portion.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

class Recipe extends Equatable with MacroTotals {
  const Recipe({required this.id, required this.food, required this.ingredients});

  factory Recipe.fromMap(Map<String, dynamic> row) => Recipe(
    id: row['id'] as String,
    food: Food.fromMap(row['foods'] as Map<String, dynamic>),
    ingredients: [
      for (final ingredientRow in row['recipe_ingredients'] as List<dynamic>)
        RecipeIngredient.fromMap(ingredientRow as Map<String, dynamic>),
    ],
  );

  final String id;
  final Food food;
  final List<RecipeIngredient> ingredients;

  @override
  List<FoodPortion> get entries => ingredients;

  @override
  List<Object?> get props => [id, food, ingredients];
}
