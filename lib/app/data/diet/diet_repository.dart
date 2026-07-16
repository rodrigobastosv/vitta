import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/datasources/http/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/recent_searches_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_diet_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_food_favorites_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_nutrition_scan_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_recipe_datasource.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';

class DietRepository {
  DietRepository({
    required this._openFoodFactsDataSource,
    required this._supabaseDietDataSource,
    required this._dietGoalsLocalDataSource,
    required this._recentSearchesLocalDataSource,
    required this._supabaseFoodFavoritesDataSource,
    required this._supabaseNutritionScanDataSource,
    required this._supabaseRecipeDataSource,
  });

  final OpenFoodFactsDataSource _openFoodFactsDataSource;
  final SupabaseDietDataSource _supabaseDietDataSource;
  final DietGoalsLocalDataSource _dietGoalsLocalDataSource;
  final RecentSearchesLocalDataSource _recentSearchesLocalDataSource;
  final SupabaseFoodFavoritesDataSource _supabaseFoodFavoritesDataSource;
  final SupabaseNutritionScanDataSource _supabaseNutritionScanDataSource;
  final SupabaseRecipeDataSource _supabaseRecipeDataSource;

  static const _sparseCatalogThreshold = 5;

  Future<Result<VTError, List<Food>>> searchFoods({required String query}) async {
    final catalogResult = await _supabaseDietDataSource.searchCatalog(query: query);
    final catalogFoods = catalogResult.when((_) => null, (foods) => foods);
    if (catalogFoods != null && catalogFoods.length >= _sparseCatalogThreshold) {
      return Success(catalogFoods);
    }
    final offResult = await _openFoodFactsDataSource.searchFoods(query: query);
    if (catalogFoods == null || catalogFoods.isEmpty) {
      return offResult;
    }
    final offFoods = offResult.when((_) => null, (foods) => foods);
    return Success(offFoods == null ? catalogFoods : _mergeByBarcode(catalogFoods, offFoods));
  }

  List<Food> _mergeByBarcode(List<Food> catalogFoods, List<Food> offFoods) {
    final catalogBarcodes = catalogFoods.map((food) => food.barcode).whereType<String>().toSet();
    return [
      ...catalogFoods,
      for (final food in offFoods)
        if (food.barcode == null || !catalogBarcodes.contains(food.barcode)) food,
    ];
  }

  Future<Result<VTError, Food>> saveFood({required Food food}) => _supabaseDietDataSource.saveFood(food: food);

  Future<Result<VTError, Food>> updateFood({required Food food}) => _supabaseDietDataSource.updateFood(food: food);

  Future<Result<VTError, FoodLog>> logFood({
    required String foodId,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
    double? quantityUnits,
  }) => _supabaseDietDataSource.logFood(
    foodId: foodId,
    loggedDate: loggedDate,
    mealType: mealType,
    quantityGrams: quantityGrams,
    quantityUnits: quantityUnits,
  );

  Future<Result<VTError, void>> copyFoodLogs({required List<FoodLogEntry> entries, required DateTime targetDate}) =>
      _supabaseDietDataSource.copyFoodLogs(entries: entries, targetDate: targetDate);

  Future<Result<VTError, DailyMacros>> getDailyMacros({required DateTime date}) async {
    final dailyLogResult = await _supabaseDietDataSource.getDailyLog(date: date);
    return dailyLogResult.when(Failure.new, (value) => Success(DailyMacros(entries: value)));
  }

  Future<Result<VTError, FoodLog>> updateFoodLog({
    required String logId,
    required MealType mealType,
    required double quantityGrams,
    double? quantityUnits,
  }) => _supabaseDietDataSource.updateFoodLog(logId: logId, mealType: mealType, quantityGrams: quantityGrams, quantityUnits: quantityUnits);

  Future<Result<VTError, void>> deleteFoodLog({required String logId}) => _supabaseDietDataSource.deleteFoodLog(logId: logId);

  Future<Result<VTError, List<Food>>> getFavoriteFoods() => _supabaseFoodFavoritesDataSource.getFavorites();

  Future<Result<VTError, void>> addFavoriteFood({required String foodId}) => _supabaseFoodFavoritesDataSource.addFavorite(foodId: foodId);

  Future<Result<VTError, void>> removeFavoriteFood({required String foodId}) =>
      _supabaseFoodFavoritesDataSource.removeFavorite(foodId: foodId);

  Future<Result<VTError, List<Recipe>>> getRecipes() => _supabaseRecipeDataSource.getRecipes();

  Future<Result<VTError, Recipe>> createRecipe({required String foodId, required List<RecipeIngredient> ingredients}) =>
      _supabaseRecipeDataSource.createRecipe(foodId: foodId, ingredients: ingredients);

  Future<Result<VTError, Recipe>> replaceRecipeIngredients({required String recipeId, required List<RecipeIngredient> ingredients}) =>
      _supabaseRecipeDataSource.replaceIngredients(recipeId: recipeId, ingredients: ingredients);

  Future<Result<VTError, void>> deleteRecipe({required String recipeId}) => _supabaseRecipeDataSource.deleteRecipe(recipeId: recipeId);

  static const _maxRecentSearches = 8;

  List<String> getRecentSearches() => _recentSearchesLocalDataSource.getRecentSearches();

  Future<List<String>> addRecentSearch({required String query}) {
    final trimmedQuery = query.trim();
    final updatedSearches = [
      trimmedQuery,
      for (final search in getRecentSearches())
        if (search.toLowerCase() != trimmedQuery.toLowerCase()) search,
    ];
    return _saveRecentSearches(updatedSearches.take(_maxRecentSearches).toList());
  }

  Future<List<String>> removeRecentSearch({required String query}) => _saveRecentSearches([
    for (final search in getRecentSearches())
      if (search != query) search,
  ]);

  Future<List<String>> clearRecentSearches() => _saveRecentSearches(const []);

  Future<List<String>> _saveRecentSearches(List<String> queries) async {
    await _recentSearchesLocalDataSource.saveRecentSearches(queries);
    return queries;
  }

  MacroGoals getMacroGoals() => _dietGoalsLocalDataSource.getGoals();

  Future<void> saveMacroGoals(MacroGoals goals) => _dietGoalsLocalDataSource.saveGoals(goals);

  Future<Result<VTError, Map<DateTime, DailyMacros>>> getMacrosInRange({required DateTime from, required DateTime to}) async {
    final monthlyLogResult = await _supabaseDietDataSource.getLogsInRange(from: from, to: to);
    return monthlyLogResult.when(Failure.new, (entries) => Success(_groupByDate(entries)));
  }

  Map<DateTime, DailyMacros> _groupByDate(List<FoodLogEntry> entries) {
    final entriesByDate = <DateTime, List<FoodLogEntry>>{};
    for (final entry in entries) {
      final date = entry.log.loggedDate;
      entriesByDate.putIfAbsent(date, () => []).add(entry);
    }
    return {for (final MapEntry(:key, :value) in entriesByDate.entries) key: DailyMacros(entries: value)};
  }

  Future<Result<VTError, String>> uploadFoodImage({required Uint8List bytes, required String fileExtension}) =>
      _supabaseDietDataSource.uploadFoodImage(bytes: bytes, fileExtension: fileExtension);

  Future<Result<VTError, ScannedNutritionFacts>> scanNutritionLabel({required String imagePath}) =>
      _supabaseNutritionScanDataSource.scanLabel(imagePath: imagePath);
}
