import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/data/water/water_repository.dart';

import '../mocks/datasources_mocks.dart';

abstract class RepositoriesFactories {
  static DietRepository buildDietRepository({
    MockOpenFoodFactsDataSource? openFoodFactsDataSource,
    MockSupabaseDietDataSource? supabaseDietDataSource,
    MockDietGoalsLocalDataSource? dietGoalsLocalDataSource,
    MockRecentSearchesLocalDataSource? recentSearchesLocalDataSource,
    MockSupabaseNutritionScanDataSource? supabaseNutritionScanDataSource,
    MockSupabaseFoodFavoritesDataSource? supabaseFoodFavoritesDataSource,
    MockSupabaseRecipeDataSource? supabaseRecipeDataSource,
  }) => DietRepository(
    openFoodFactsDataSource: openFoodFactsDataSource ?? MockOpenFoodFactsDataSource(),
    supabaseDietDataSource: supabaseDietDataSource ?? MockSupabaseDietDataSource(),
    dietGoalsLocalDataSource: dietGoalsLocalDataSource ?? MockDietGoalsLocalDataSource(),
    recentSearchesLocalDataSource: recentSearchesLocalDataSource ?? MockRecentSearchesLocalDataSource(),
    supabaseFoodFavoritesDataSource: supabaseFoodFavoritesDataSource ?? MockSupabaseFoodFavoritesDataSource(),
    supabaseNutritionScanDataSource: supabaseNutritionScanDataSource ?? MockSupabaseNutritionScanDataSource(),
    supabaseRecipeDataSource: supabaseRecipeDataSource ?? MockSupabaseRecipeDataSource(),
  );

  static WaterRepository buildWaterRepository({
    MockSupabaseWaterDataSource? supabaseWaterDataSource,
    MockWaterLocalDataSource? waterLocalDataSource,
  }) => WaterRepository(
    supabaseWaterDataSource: supabaseWaterDataSource ?? MockSupabaseWaterDataSource(),
    waterLocalDataSource: waterLocalDataSource ?? MockWaterLocalDataSource(),
  );
}
