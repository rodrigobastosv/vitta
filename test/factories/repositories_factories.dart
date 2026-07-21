import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/data/water/water_repository.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';

import '../mocks/datasources_mocks.dart';

abstract class RepositoriesFactories {
  static DietRepository buildDietRepository({
    MockOpenFoodFactsDataSource? openFoodFactsDataSource,
    MockSupabaseDietDataSource? supabaseDietDataSource,
    MockDietGoalsLocalDataSource? dietGoalsLocalDataSource,
    MockRecentSearchesLocalDataSource? recentSearchesLocalDataSource,
    MockSupabaseNutritionScanDataSource? supabaseNutritionScanDataSource,
    MockSupabaseMealScanDataSource? supabaseMealScanDataSource,
    MockSupabaseFoodFavoritesDataSource? supabaseFoodFavoritesDataSource,
    MockSupabaseRecipeDataSource? supabaseRecipeDataSource,
    MockDietIntroLocalDataSource? dietIntroLocalDataSource,
  }) => DietRepository(
    openFoodFactsDataSource: openFoodFactsDataSource ?? MockOpenFoodFactsDataSource(),
    supabaseDietDataSource: supabaseDietDataSource ?? MockSupabaseDietDataSource(),
    dietGoalsLocalDataSource: dietGoalsLocalDataSource ?? MockDietGoalsLocalDataSource(),
    recentSearchesLocalDataSource: recentSearchesLocalDataSource ?? MockRecentSearchesLocalDataSource(),
    supabaseFoodFavoritesDataSource: supabaseFoodFavoritesDataSource ?? MockSupabaseFoodFavoritesDataSource(),
    supabaseMealScanDataSource: supabaseMealScanDataSource ?? MockSupabaseMealScanDataSource(),
    supabaseNutritionScanDataSource: supabaseNutritionScanDataSource ?? MockSupabaseNutritionScanDataSource(),
    supabaseRecipeDataSource: supabaseRecipeDataSource ?? MockSupabaseRecipeDataSource(),
    dietIntroLocalDataSource: dietIntroLocalDataSource ?? MockDietIntroLocalDataSource(),
  );

  static WaterRepository buildWaterRepository({MockSupabaseWaterDataSource? supabaseWaterDataSource, MockWaterLocalDataSource? waterLocalDataSource}) =>
      WaterRepository(
        supabaseWaterDataSource: supabaseWaterDataSource ?? MockSupabaseWaterDataSource(),
        waterLocalDataSource: waterLocalDataSource ?? MockWaterLocalDataSource(),
      );

  static WorkoutRepository buildWorkoutRepository({
    MockSupabaseExerciseDataSource? supabaseExerciseDataSource,
    MockSupabaseWorkoutDataSource? supabaseWorkoutDataSource,
    MockSupabaseRoutineDataSource? supabaseRoutineDataSource,
    MockWorkoutLocalDataSource? workoutLocalDataSource,
  }) => WorkoutRepository(
    supabaseExerciseDataSource: supabaseExerciseDataSource ?? MockSupabaseExerciseDataSource(),
    supabaseWorkoutDataSource: supabaseWorkoutDataSource ?? MockSupabaseWorkoutDataSource(),
    supabaseRoutineDataSource: supabaseRoutineDataSource ?? MockSupabaseRoutineDataSource(),
    workoutLocalDataSource: workoutLocalDataSource ?? MockWorkoutLocalDataSource(),
  );
}
