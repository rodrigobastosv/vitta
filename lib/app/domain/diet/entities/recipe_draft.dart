import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_portion.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

class RecipeDraft extends Equatable with MacroTotals {
  const RecipeDraft({this.name = '', this.ingredients = const [], this.imageUrl});

  factory RecipeDraft.fromRecipe(Recipe recipe) =>
      RecipeDraft(name: recipe.food.name, ingredients: recipe.ingredients, imageUrl: recipe.food.imageUrl);

  final String name;
  final List<RecipeIngredient> ingredients;
  final String? imageUrl;

  @override
  List<FoodPortion> get entries => ingredients;

  bool get isComplete => name.trim().isNotEmpty && ingredients.isNotEmpty && totalGrams > 0;

  double per100g(double total) => totalGrams <= 0 ? 0 : total / totalGrams * 100;

  Food toFood({String? id}) => Food(
    id: id,
    name: name.trim(),
    source: .recipe,
    caloriesPer100g: per100g(totalCalories),
    proteinPer100g: per100g(totalProtein),
    carbsPer100g: per100g(totalCarbs),
    fatPer100g: per100g(totalFat),
    fiberPer100g: per100g(totalFiber),
    micronutrientsPer100g: {for (final MapEntry(:key, :value) in micronutrientTotals.entries) key: per100g(value)},
    imageUrl: imageUrl,
  );

  RecipeDraft copyWith({String? name, List<RecipeIngredient>? ingredients, String? imageUrl}) =>
      RecipeDraft(name: name ?? this.name, ingredients: ingredients ?? this.ingredients, imageUrl: imageUrl ?? this.imageUrl);

  @override
  List<Object?> get props => [name, ingredients, imageUrl];
}
