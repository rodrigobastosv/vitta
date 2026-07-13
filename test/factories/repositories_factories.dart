import 'package:vitta/app/data/diet/diet_repository.dart';

import '../mocks/datasources_mocks.dart';

abstract class RepositoriesFactories {
  static DietRepository buildDietRepository({
    MockOpenFoodFactsDataSource? openFoodFactsDataSource,
    MockSupabaseDietDataSource? supabaseDietDataSource,
    MockDietGoalsLocalDataSource? dietGoalsLocalDataSource,
  }) => DietRepository(
    openFoodFactsDataSource: openFoodFactsDataSource ?? MockOpenFoodFactsDataSource(),
    supabaseDietDataSource: supabaseDietDataSource ?? MockSupabaseDietDataSource(),
    dietGoalsLocalDataSource: dietGoalsLocalDataSource ?? MockDietGoalsLocalDataSource(),
  );
}
