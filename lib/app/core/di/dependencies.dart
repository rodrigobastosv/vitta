import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/http/vt_http_client.dart';
import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/data/diet/datasources/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase_diet_datasource.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/onboarding/onboarding_repository.dart';
import 'package:vitta/app/data/settings/settings_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/supabase_water_datasource.dart';
import 'package:vitta/app/data/water/water_local_datasource.dart';
import 'package:vitta/app/data/water/water_repository.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';

final G = GetIt.instance;

void setupDependencies({required Box<dynamic> appBox, required SupabaseService supabaseService}) {
  G.registerLazySingleton<LocalStorageService>(() => LocalStorageService(box: appBox));
  G.registerLazySingleton(() => SettingsLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => WaterLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => OnboardingLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => OnboardingRepository(onboardingLocalDataSource: G()));
  G.registerLazySingleton(() => AppCubit(settingsLocalDataSource: G()));

  G.registerLazySingleton(() => supabaseService);
  G.registerLazySingleton(() => VTHttpClient(baseUrl: 'https://world.openfoodfacts.org'));
  G.registerLazySingleton(() => OpenFoodFactsDataSource(httpClient: G()));
  G.registerLazySingleton(() => SupabaseDietDataSource(supabaseService: G()));
  G.registerLazySingleton(() => DietRepository(openFoodFactsDataSource: G(), supabaseDietDataSource: G()));
  G.registerLazySingleton(() => SupabaseWaterDataSource(supabaseService: G()));
  G.registerLazySingleton(() => WaterRepository(supabaseWaterDataSource: G()));

  G.registerFactory(() => SearchFoodsUseCase(dietRepository: G()));
  G.registerFactory(() => LogFoodUseCase(dietRepository: G()));
  G.registerFactory(() => GetDailyMacrosUseCase(dietRepository: G()));
  G.registerFactory(() => DeleteFoodLogUseCase(dietRepository: G()));
  G.registerFactory(() => LogWaterUseCase(waterRepository: G()));
  G.registerFactory(() => GetDailyWaterUseCase(waterRepository: G()));
  G.registerFactory(() => DeleteWaterLogUseCase(waterRepository: G()));
  G.registerFactory(() => CompleteOnboardingUseCase(onboardingRepository: G()));

  G.registerFactory(() => DietCubit(getDailyMacrosUseCase: G(), deleteFoodLogUseCase: G()));
  G.registerFactory(() => FoodSearchCubit(searchFoodsUseCase: G(), logFoodUseCase: G()));
  G.registerFactory(() => OnboardingCubit(completeOnboardingUseCase: G()));
  G.registerFactory(
    () => WaterCubit(
      getDailyWaterUseCase: G(),
      logWaterUseCase: G(),
      deleteWaterLogUseCase: G(),
      waterLocalDataSource: G(),
    ),
  );
}
