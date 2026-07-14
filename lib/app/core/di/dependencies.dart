import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/http/vt_http_client.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/logging/console_log_destination.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';
import 'package:vitta/app/core/services/logging/sentry_log_destination.dart';
import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/text_recognition/text_recognition_service.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/data/auth/datasources/supabase_auth_datasource.dart';
import 'package:vitta/app/data/diet/datasources/http/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/ocr/nutrition_ocr_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_diet_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_recipe_datasource.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/onboarding/onboarding_repository.dart';
import 'package:vitta/app/data/settings/settings_local_datasource.dart';
import 'package:vitta/app/data/settings/settings_repository.dart';
import 'package:vitta/app/data/sleep/datasources/supabase_sleep_datasource.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/supabase/supabase_water_datasource.dart';
import 'package:vitta/app/data/water/water_repository.dart';
import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_in_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_up_use_case.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/use_cases/copy_food_logs_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macros_in_range_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_recipes_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/scan_nutrition_label_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/update_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/upload_food_image_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/has_seen_onboarding_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/save_app_settings_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/delete_sleep_log_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/log_sleep_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';

final G = GetIt.instance;

void setupDependencies({required Box<dynamic> appBox, required SupabaseService supabaseService}) {
  G.registerLazySingleton<LocalStorageService>(() => LocalStorageService(box: appBox));
  G.registerLazySingleton(() => SettingsLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => WaterLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => OnboardingLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => OnboardingRepository(onboardingLocalDataSource: G()));
  G.registerLazySingleton(() => SettingsRepository(settingsLocalDataSource: G()));
  G.registerFactory(() => GetAppSettingsUseCase(settingsRepository: G()));
  G.registerFactory(() => SaveAppSettingsUseCase(settingsRepository: G()));
  G.registerLazySingleton(() => AppCubit(getAppSettingsUseCase: G(), saveAppSettingsUseCase: G()));

  G.registerLazySingleton(() => supabaseService);
  G.registerLazySingleton(ImagePickerService.new);
  Log.service = LoggingService(destinations: const [ConsoleLogDestination(), SentryLogDestination()]);
  G.registerLazySingleton(() => VTHttpClient(baseUrl: 'https://world.openfoodfacts.org'));
  G.registerLazySingleton(() => OpenFoodFactsDataSource(httpClient: G()));
  G.registerLazySingleton(() => SupabaseDietDataSource(supabaseService: G()));
  G.registerLazySingleton(() => DietGoalsLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(TextRecognitionService.new);
  G.registerLazySingleton(() => NutritionOcrDataSource(textRecognitionService: G()));
  G.registerLazySingleton(() => SupabaseRecipeDataSource(supabaseService: G()));
  G.registerLazySingleton(
    () => DietRepository(
      openFoodFactsDataSource: G(),
      supabaseDietDataSource: G(),
      dietGoalsLocalDataSource: G(),
      nutritionOcrDataSource: G(),
      supabaseRecipeDataSource: G(),
    ),
  );
  G.registerLazySingleton(() => SupabaseWaterDataSource(supabaseService: G()));
  G.registerLazySingleton(() => WaterRepository(supabaseWaterDataSource: G()));
  G.registerLazySingleton(() => SupabaseSleepDataSource(supabaseService: G()));
  G.registerLazySingleton(() => SleepRepository(supabaseSleepDataSource: G()));
  G.registerLazySingleton(() => SupabaseAuthDataSource(supabaseService: G()));
  G.registerLazySingleton(() => AuthRepository(supabaseAuthDataSource: G()));

  G.registerFactory(() => SearchFoodsUseCase(dietRepository: G()));
  G.registerFactory(() => LogFoodUseCase(dietRepository: G()));
  G.registerFactory(() => GetDailyMacrosUseCase(dietRepository: G()));
  G.registerFactory(() => DeleteFoodLogUseCase(dietRepository: G()));
  G.registerFactory(() => UpdateFoodLogUseCase(dietRepository: G()));
  G.registerFactory(() => GetRecipesUseCase(dietRepository: G()));
  G.registerFactory(() => SaveRecipeUseCase(dietRepository: G()));
  G.registerFactory(() => DeleteRecipeUseCase(dietRepository: G()));
  G.registerFactory(() => GetMacroGoalsUseCase(dietRepository: G()));
  G.registerFactory(() => SaveMacroGoalsUseCase(dietRepository: G()));
  G.registerFactory(() => GetMacrosInRangeUseCase(dietRepository: G()));
  G.registerFactory(() => CopyFoodLogsUseCase(dietRepository: G()));
  G.registerFactory(() => UploadFoodImageUseCase(dietRepository: G()));
  G.registerFactory(() => ScanNutritionLabelUseCase(dietRepository: G()));
  G.registerFactory(() => LogWaterUseCase(waterRepository: G()));
  G.registerFactory(() => GetDailyWaterUseCase(waterRepository: G()));
  G.registerFactory(() => DeleteWaterLogUseCase(waterRepository: G()));
  G.registerFactory(() => LogSleepUseCase(sleepRepository: G()));
  G.registerFactory(() => GetRecentSleepLogsUseCase(sleepRepository: G()));
  G.registerFactory(() => DeleteSleepLogUseCase(sleepRepository: G()));
  G.registerFactory(() => CompleteOnboardingUseCase(onboardingRepository: G()));
  G.registerFactory(() => HasSeenOnboardingUseCase(onboardingRepository: G()));
  G.registerFactory(() => GetUserUseCase(authRepository: G()));
  G.registerFactory(() => SignUpUseCase(authRepository: G()));
  G.registerFactory(() => SignInUseCase(authRepository: G()));
  G.registerFactory(() => SignOutUseCase(authRepository: G()));

  G.registerFactory(
    () => DietCubit(
      getDailyMacrosUseCase: G(),
      deleteFoodLogUseCase: G(),
      updateFoodLogUseCase: G(),
      getMacroGoalsUseCase: G(),
      getMacrosInRangeUseCase: G(),
      getAppSettingsUseCase: G(),
    ),
  );
  G.registerFactory(() => DietHistoryCubit(getMacrosInRangeUseCase: G(), getMacroGoalsUseCase: G()));
  G.registerFactoryParam<CopyMealsCubit, DateTime, void>(
    (targetDate, _) =>
        CopyMealsCubit(getMacrosInRangeUseCase: G(), getMacroGoalsUseCase: G(), copyFoodLogsUseCase: G(), targetDate: targetDate),
  );
  G.registerFactory(() => MacroGoalsCubit(getMacroGoalsUseCase: G(), saveMacroGoalsUseCase: G()));
  G.registerFactory(() => FoodSearchCubit(searchFoodsUseCase: G(), logFoodUseCase: G(), getAppSettingsUseCase: G()));
  G.registerFactory(() => CustomFoodCubit(uploadFoodImageUseCase: G(), scanNutritionLabelUseCase: G(), imagePickerService: G()));
  G.registerFactory(() => RecipesCubit(getRecipesUseCase: G(), deleteRecipeUseCase: G()));
  G.registerFactoryParam<RecipeFormCubit, Recipe?, void>(
    (recipe, _) => RecipeFormCubit(
      saveRecipeUseCase: G(),
      getAppSettingsUseCase: G(),
      uploadFoodImageUseCase: G(),
      imagePickerService: G(),
      recipe: recipe,
    ),
  );
  G.registerFactory(() => OnboardingCubit(completeOnboardingUseCase: G()));
  G.registerFactory(() => AuthCubit(getUserUseCase: G(), signUpUseCase: G(), signInUseCase: G(), signOutUseCase: G()));
  G.registerFactory(
    () => WaterCubit(
      getDailyWaterUseCase: G(),
      logWaterUseCase: G(),
      deleteWaterLogUseCase: G(),
      waterLocalDataSource: G(),
      getAppSettingsUseCase: G(),
    ),
  );
  G.registerFactory(() => SleepCubit(getRecentSleepLogsUseCase: G(), logSleepUseCase: G(), deleteSleepLogUseCase: G()));
}
