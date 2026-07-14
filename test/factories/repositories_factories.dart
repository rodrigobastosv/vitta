import 'package:vitta/app/data/diet/diet_repository.dart';

import '../mocks/datasources_mocks.dart';

abstract class RepositoriesFactories {
  static DietRepository buildDietRepository({
    MockOpenFoodFactsDataSource? openFoodFactsDataSource,
    MockSupabaseDietDataSource? supabaseDietDataSource,
    MockDietGoalsLocalDataSource? dietGoalsLocalDataSource,
    MockNutritionOcrDataSource? nutritionOcrDataSource,
    MockSupabaseRecipeDataSource? supabaseRecipeDataSource,
  }) => DietRepository(
    openFoodFactsDataSource: openFoodFactsDataSource ?? MockOpenFoodFactsDataSource(),
    supabaseDietDataSource: supabaseDietDataSource ?? MockSupabaseDietDataSource(),
    dietGoalsLocalDataSource: dietGoalsLocalDataSource ?? MockDietGoalsLocalDataSource(),
    nutritionOcrDataSource: nutritionOcrDataSource ?? MockNutritionOcrDataSource(),
    supabaseRecipeDataSource: supabaseRecipeDataSource ?? MockSupabaseRecipeDataSource(),
  );
}
