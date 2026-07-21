import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_recipe_ingredient_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_recipe_request.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

class SupabaseRecipeDataSource {
  SupabaseRecipeDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  String get _userId => _supabaseService.currentUserId;

  static final String _recipeSelect =
      '*, ${SupabaseTable.foods.wireName}(*), '
      '${SupabaseTable.recipeIngredients.wireName}(*, ${SupabaseTable.foods.wireName}(*))';

  Future<Result<VTError, List<Recipe>>> getRecipes() async {
    try {
      final rows = await _supabaseService.from(.recipes).select(_recipeSelect).eq('user_id', _userId).order('created_at', ascending: false);
      return Success(rows.map(Recipe.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load recipes', cause: error));
    }
  }

  Future<Result<VTError, Recipe>> createRecipe({required String foodId, required List<RecipeIngredient> ingredients}) async {
    try {
      final recipeRow = await _supabaseService.from(.recipes).insert(CreateRecipeRequest(userId: _userId, foodId: foodId).toJson()).select().single();
      final recipeId = recipeRow['id'] as String;
      await _supabaseService.from(.recipeIngredients).insert([
        for (final ingredient in ingredients)
          CreateRecipeIngredientRequest(recipeId: recipeId, foodId: ingredient.food.id!, quantityGrams: ingredient.quantityGrams).toJson(),
      ]);
      final createdRow = await _supabaseService.from(.recipes).select(_recipeSelect).eq('id', recipeId).single();
      return Success(Recipe.fromMap(createdRow));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create recipe', cause: error));
    }
  }

  Future<Result<VTError, Recipe>> replaceIngredients({required String recipeId, required List<RecipeIngredient> ingredients}) async {
    try {
      await _supabaseService.from(.recipeIngredients).delete().eq('recipe_id', recipeId);
      await _supabaseService.from(.recipeIngredients).insert([
        for (final ingredient in ingredients)
          CreateRecipeIngredientRequest(recipeId: recipeId, foodId: ingredient.food.id!, quantityGrams: ingredient.quantityGrams).toJson(),
      ]);
      final updatedRow = await _supabaseService.from(.recipes).select(_recipeSelect).eq('id', recipeId).single();
      return Success(Recipe.fromMap(updatedRow));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update recipe $recipeId', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteRecipe({required String recipeId}) async {
    try {
      await _supabaseService.from(.recipes).delete().eq('id', recipeId).eq('user_id', _userId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete recipe $recipeId', cause: error));
    }
  }
}
