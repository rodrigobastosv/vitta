import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/data/diet/datasources/http/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_diet_datasource.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';

class MockWaterLocalDataSource extends Mock implements WaterLocalDataSource {}

class MockOnboardingLocalDataSource extends Mock implements OnboardingLocalDataSource {}

class MockSupabaseDietDataSource extends Mock implements SupabaseDietDataSource {}

class MockOpenFoodFactsDataSource extends Mock implements OpenFoodFactsDataSource {}

class MockDietGoalsLocalDataSource extends Mock implements DietGoalsLocalDataSource {}
