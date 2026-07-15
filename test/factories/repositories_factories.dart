import 'package:vitta/app/data/diet/diet_repository.dart';

import '../mocks/datasources_mocks.dart';

abstract class RepositoriesFactories {
  static DietRepository buildDietRepository({
    MockOpenFoodFactsDataSource? openFoodFactsDataSource,
    MockSupabaseDietDataSource? supabaseDietDataSource,
    MockDietGoalsLocalDataSource? dietGoalsLocalDataSource,
    MockSupabaseNutritionScanDataSource? supabaseNutritionScanDataSource,
    MockSupabaseFoodFavoritesDataSource? supabaseFoodFavoritesDataSource,
    MockSupabaseRecipeDataSource? supabaseRecipeDataSource,
  }) => DietRepository(
    openFoodFactsDataSource: openFoodFactsDataSource ?? MockOpenFoodFactsDataSource(),
    supabaseDietDataSource: supabaseDietDataSource ?? MockSupabaseDietDataSource(),
    dietGoalsLocalDataSource: dietGoalsLocalDataSource ?? MockDietGoalsLocalDataSource(),
    supabaseFoodFavoritesDataSource: supabaseFoodFavoritesDataSource ?? MockSupabaseFoodFavoritesDataSource(),
    supabaseNutritionScanDataSource: supabaseNutritionScanDataSource ?? MockSupabaseNutritionScanDataSource(),
    supabaseRecipeDataSource: supabaseRecipeDataSource ?? MockSupabaseRecipeDataSource(),
  );
}
