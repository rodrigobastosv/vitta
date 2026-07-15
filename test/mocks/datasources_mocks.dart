import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/data/diet/datasources/http/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/recent_searches_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_diet_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_food_favorites_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_nutrition_scan_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_recipe_datasource.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/supabase/supabase_water_datasource.dart';

class MockWaterLocalDataSource extends Mock implements WaterLocalDataSource {}

class MockOnboardingLocalDataSource extends Mock implements OnboardingLocalDataSource {}

class MockSupabaseDietDataSource extends Mock implements SupabaseDietDataSource {}

class MockSupabaseRecipeDataSource extends Mock implements SupabaseRecipeDataSource {}

class MockOpenFoodFactsDataSource extends Mock implements OpenFoodFactsDataSource {}

class MockDietGoalsLocalDataSource extends Mock implements DietGoalsLocalDataSource {}

class MockSupabaseNutritionScanDataSource extends Mock implements SupabaseNutritionScanDataSource {}

class MockSupabaseFoodFavoritesDataSource extends Mock implements SupabaseFoodFavoritesDataSource {}

class MockRecentSearchesLocalDataSource extends Mock implements RecentSearchesLocalDataSource {}

class MockSupabaseWaterDataSource extends Mock implements SupabaseWaterDataSource {}
