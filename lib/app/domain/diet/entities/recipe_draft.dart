import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_portion.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

class RecipeDraft extends Equatable with MacroTotals {
  const RecipeDraft({this.name = '', this.ingredients = const []});

  final String name;
  final List<RecipeIngredient> ingredients;

  @override
  List<FoodPortion> get entries => ingredients;

  bool get isComplete => name.trim().isNotEmpty && ingredients.isNotEmpty && totalGrams > 0;

  double per100g(double total) => totalGrams <= 0 ? 0 : total / totalGrams * 100;

  Food toFood() => Food(
    name: name.trim(),
    source: .recipe,
    caloriesPer100g: per100g(totalCalories),
    proteinPer100g: per100g(totalProtein),
    carbsPer100g: per100g(totalCarbs),
    fatPer100g: per100g(totalFat),
    fiberPer100g: per100g(totalFiber),
    micronutrientsPer100g: {
      for (final MapEntry(:key, :value) in micronutrientTotals.entries) key: per100g(value),
    },
  );

  RecipeDraft copyWith({String? name, List<RecipeIngredient>? ingredients}) =>
      RecipeDraft(name: name ?? this.name, ingredients: ingredients ?? this.ingredients);

  @override
  List<Object?> get props => [name, ingredients];
}
