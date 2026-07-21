import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/data/diet/datasources/http/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_intro_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/recent_searches_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_diet_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_food_favorites_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_meal_scan_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_nutrition_scan_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_recipe_datasource.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/reminder/datasources/supabase/supabase_reminder_datasource.dart';
import 'package:vitta/app/data/sleep/datasources/local/sleep_local_datasource.dart';
import 'package:vitta/app/data/sleep/datasources/supabase/supabase_sleep_datasource.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/supabase/supabase_water_datasource.dart';
import 'package:vitta/app/data/workout/datasources/local/workout_local_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_exercise_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_routine_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_workout_datasource.dart';

class MockWaterLocalDataSource extends Mock implements WaterLocalDataSource {}

class MockOnboardingLocalDataSource extends Mock implements OnboardingLocalDataSource {}

class MockSupabaseDietDataSource extends Mock implements SupabaseDietDataSource {}

class MockSupabaseRecipeDataSource extends Mock implements SupabaseRecipeDataSource {}

class MockOpenFoodFactsDataSource extends Mock implements OpenFoodFactsDataSource {}

class MockDietGoalsLocalDataSource extends Mock implements DietGoalsLocalDataSource {}

class MockDietIntroLocalDataSource extends Mock implements DietIntroLocalDataSource {}

class MockSupabaseNutritionScanDataSource extends Mock implements SupabaseNutritionScanDataSource {}

class MockSupabaseMealScanDataSource extends Mock implements SupabaseMealScanDataSource {}

class MockSupabaseFoodFavoritesDataSource extends Mock implements SupabaseFoodFavoritesDataSource {}

class MockRecentSearchesLocalDataSource extends Mock implements RecentSearchesLocalDataSource {}

class MockSupabaseWaterDataSource extends Mock implements SupabaseWaterDataSource {}

class MockSupabaseWorkoutDataSource extends Mock implements SupabaseWorkoutDataSource {}

class MockSupabaseExerciseDataSource extends Mock implements SupabaseExerciseDataSource {}

class MockSupabaseRoutineDataSource extends Mock implements SupabaseRoutineDataSource {}

class MockWorkoutLocalDataSource extends Mock implements WorkoutLocalDataSource {}

class MockSupabaseReminderDataSource extends Mock implements SupabaseReminderDataSource {}

class MockSupabaseSleepDataSource extends Mock implements SupabaseSleepDataSource {}

class MockSleepLocalDataSource extends Mock implements SleepLocalDataSource {}
