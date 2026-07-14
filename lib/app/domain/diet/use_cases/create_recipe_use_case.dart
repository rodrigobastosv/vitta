import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

class CreateRecipeUseCase {
  CreateRecipeUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, Recipe>> call({required RecipeDraft draft}) async {
    final savedIngredientsResult = await _saveIngredientFoods(draft.ingredients);
    final ingredientsError = savedIngredientsResult.when((error) => error, (_) => null);
    if (ingredientsError != null) {
      return Failure(ingredientsError);
    }
    final savedIngredients = savedIngredientsResult.when((_) => <RecipeIngredient>[], (value) => value);

    final recipeFoodResult = await _dietRepository.saveFood(food: draft.toFood());
    return recipeFoodResult.when(
      (error) => Future.value(Failure(error)),
      (recipeFood) => _dietRepository.createRecipe(foodId: recipeFood.id!, ingredients: savedIngredients),
    );
  }

  Future<Result<VTError, List<RecipeIngredient>>> _saveIngredientFoods(List<RecipeIngredient> ingredients) async {
    final saved = <RecipeIngredient>[];
    for (final ingredient in ingredients) {
      if (ingredient.food.id != null) {
        saved.add(ingredient);
        continue;
      }
      final savedFoodResult = await _dietRepository.saveFood(food: ingredient.food);
      final error = savedFoodResult.when((error) => error, (_) => null);
      if (error != null) {
        return Failure(error);
      }
      saved.add(
        RecipeIngredient(food: savedFoodResult.when((_) => ingredient.food, (value) => value), quantityGrams: ingredient.quantityGrams),
      );
    }
    return Success(saved);
  }
}
