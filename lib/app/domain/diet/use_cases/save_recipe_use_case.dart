import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

class SaveRecipeUseCase {
  SaveRecipeUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, Recipe>> call({required RecipeDraft draft, Recipe? recipe}) async {
    final savedIngredientsResult = await _saveIngredientFoods(draft.ingredients);
    final ingredientsError = savedIngredientsResult.when((error) => error, (_) => null);
    if (ingredientsError != null) {
      return Failure(ingredientsError);
    }
    final savedIngredients = savedIngredientsResult.when((_) => <RecipeIngredient>[], (value) => value);
    return recipe == null ? _create(draft, savedIngredients) : _update(recipe, draft, savedIngredients);
  }

  Future<Result<VTError, Recipe>> _create(RecipeDraft draft, List<RecipeIngredient> ingredients) async {
    final recipeFoodResult = await _dietRepository.saveFood(food: draft.toFood());
    return recipeFoodResult.when(
      (error) => Future.value(Failure(error)),
      (recipeFood) => _dietRepository.createRecipe(foodId: recipeFood.id!, ingredients: ingredients),
    );
  }

  Future<Result<VTError, Recipe>> _update(Recipe recipe, RecipeDraft draft, List<RecipeIngredient> ingredients) async {
    final updatedFoodResult = await _dietRepository.updateFood(food: draft.toFood(id: recipe.food.id));
    return updatedFoodResult.when(
      (error) => Future.value(Failure(error)),
      (_) => _dietRepository.replaceRecipeIngredients(recipeId: recipe.id, ingredients: ingredients),
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
