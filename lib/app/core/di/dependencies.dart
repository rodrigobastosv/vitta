import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/http/vt_http_client.dart';
import 'package:vitta/app/core/services/health/health_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/logging/console_log_destination.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';
import 'package:vitta/app/core/services/logging/sentry_log_destination.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/core/services/purchases/purchase_service.dart';
import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/data/auth/datasources/supabase_auth_datasource.dart';
import 'package:vitta/app/data/body_profile/body_profile_local_datasource.dart';
import 'package:vitta/app/data/body_profile/body_profile_repository.dart';
import 'package:vitta/app/data/body_weight/body_weight_repository.dart';
import 'package:vitta/app/data/body_weight/datasources/supabase/supabase_body_weight_datasource.dart';
import 'package:vitta/app/data/diet/datasources/http/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_intro_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/recent_searches_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_diet_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_food_favorites_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_meal_scan_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_nutrition_scan_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_recipe_datasource.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/onboarding/onboarding_repository.dart';
import 'package:vitta/app/data/premium/datasources/supabase_premium_datasource.dart';
import 'package:vitta/app/data/premium/premium_repository.dart';
import 'package:vitta/app/data/progress_photos/datasources/supabase/supabase_progress_photos_datasource.dart';
import 'package:vitta/app/data/progress_photos/progress_photos_repository.dart';
import 'package:vitta/app/data/reminder/datasources/supabase/supabase_reminder_datasource.dart';
import 'package:vitta/app/data/reminder/reminder_repository.dart';
import 'package:vitta/app/data/settings/settings_local_datasource.dart';
import 'package:vitta/app/data/settings/settings_repository.dart';
import 'package:vitta/app/data/sleep/datasources/local/sleep_local_datasource.dart';
import 'package:vitta/app/data/sleep/datasources/supabase/supabase_sleep_datasource.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/supabase/supabase_water_datasource.dart';
import 'package:vitta/app/data/water/water_repository.dart';
import 'package:vitta/app/data/workout/datasources/local/workout_local_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_exercise_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_routine_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_workout_datasource.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/auth/use_cases/delete_account_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_in_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_up_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/update_profile_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/upload_avatar_use_case.dart';
import 'package:vitta/app/domain/body_profile/use_cases/get_body_profile_use_case.dart';
import 'package:vitta/app/domain/body_profile/use_cases/save_body_profile_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/delete_body_weight_log_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_body_weight_in_range_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_latest_body_weight_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_recent_body_weight_logs_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/log_body_weight_use_case.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/use_cases/add_recent_search_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/clear_recent_searches_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/copy_food_logs_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/favorite_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_favorite_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macros_in_range_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_recent_searches_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_recently_logged_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_recipes_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/has_seen_diet_intro_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_scanned_meal_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/mark_diet_intro_seen_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/remove_recent_search_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/scan_meal_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/scan_nutrition_label_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/unfavorite_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/update_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/upload_food_image_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/has_seen_onboarding_use_case.dart';
import 'package:vitta/app/domain/premium/use_cases/get_premium_status_use_case.dart';
import 'package:vitta/app/domain/progress_photos/use_cases/add_progress_photo_use_case.dart';
import 'package:vitta/app/domain/progress_photos/use_cases/delete_progress_photo_use_case.dart';
import 'package:vitta/app/domain/progress_photos/use_cases/get_progress_photos_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/complete_reminder_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/create_reminder_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/delete_reminder_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/get_reminders_for_date_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/get_reminders_in_range_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/update_reminder_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/save_app_settings_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/delete_sleep_log_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_in_range_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_last_synced_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/import_sleep_from_health_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/log_sleep_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/save_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_in_range_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/use_cases/add_exercise_to_workout_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_routine_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_workout_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_daily_workouts_in_range_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_exercise_progression_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_last_sets_by_exercise_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_logged_exercises_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_rest_duration_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_routine_cycle_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_routines_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_workouts_for_date_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/has_seen_workout_intro_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/log_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/mark_workout_intro_seen_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/remove_workout_exercise_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/reorder_routines_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/save_rest_duration_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/save_routine_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/search_exercises_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/set_workout_exercise_completed_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/start_workout_from_routine_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/update_set_use_case.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_cubit.dart';
import 'package:vitta/app/presentation/pages/objective/objective_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_cubit.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_cubit.dart';
import 'package:vitta/app/presentation/pages/routines/routines_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_cubit.dart';
import 'package:vitta/app/presentation/pages/workout/workout_cubit.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_cubit.dart';

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
  G.registerLazySingleton(() => PremiumCubit(getPremiumStatusUseCase: G(), purchaseService: G()));
  G.registerFactory(() => GetRestDurationUseCase(workoutRepository: G()));
  G.registerFactory(() => SaveRestDurationUseCase(workoutRepository: G()));
  G.registerLazySingleton(() => RestTimerCubit(getRestDurationUseCase: G(), saveRestDurationUseCase: G()));
  G.registerFactoryParam<ExerciseWorkoutCubit, ExerciseWorkoutExtra, void>(
    (extra, _) => ExerciseWorkoutCubit(extra: extra, logSetUseCase: G(), updateSetUseCase: G(), deleteSetUseCase: G(), setWorkoutExerciseCompletedUseCase: G()),
  );

  G.registerLazySingleton(() => supabaseService);
  G.registerLazySingleton(ImagePickerService.new);
  G.registerLazySingleton(HealthService.new);
  G.registerLazySingleton(NotificationService.new);
  G.registerLazySingleton(PurchaseService.new);
  Log.service = LoggingService(destinations: const [ConsoleLogDestination(), SentryLogDestination()]);
  G.registerLazySingleton(() => VTHttpClient(baseUrl: 'https://world.openfoodfacts.org'));
  G.registerLazySingleton(() => OpenFoodFactsDataSource(httpClient: G()));
  G.registerLazySingleton(() => SupabaseDietDataSource(supabaseService: G()));
  G.registerLazySingleton(() => DietGoalsLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => BodyProfileLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => BodyProfileRepository(bodyProfileLocalDataSource: G()));
  G.registerLazySingleton(() => RecentSearchesLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => DietIntroLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => SupabaseNutritionScanDataSource(supabaseService: G()));
  G.registerLazySingleton(() => SupabaseMealScanDataSource(supabaseService: G()));
  G.registerLazySingleton(() => SupabaseRecipeDataSource(supabaseService: G()));
  G.registerLazySingleton(() => SupabaseFoodFavoritesDataSource(supabaseService: G()));
  G.registerLazySingleton(
    () => DietRepository(
      openFoodFactsDataSource: G(),
      supabaseDietDataSource: G(),
      dietGoalsLocalDataSource: G(),
      recentSearchesLocalDataSource: G(),
      supabaseFoodFavoritesDataSource: G(),
      supabaseMealScanDataSource: G(),
      supabaseNutritionScanDataSource: G(),
      supabaseRecipeDataSource: G(),
      dietIntroLocalDataSource: G(),
    ),
  );
  G.registerLazySingleton(() => SupabaseWaterDataSource(supabaseService: G()));
  G.registerLazySingleton(() => WaterRepository(supabaseWaterDataSource: G(), waterLocalDataSource: G()));
  G.registerLazySingleton(() => SupabaseBodyWeightDataSource(supabaseService: G()));
  G.registerLazySingleton(() => BodyWeightRepository(supabaseBodyWeightDataSource: G()));
  G.registerLazySingleton(() => SupabaseSleepDataSource(supabaseService: G()));
  G.registerLazySingleton(() => SleepLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(() => SleepRepository(supabaseSleepDataSource: G(), sleepLocalDataSource: G()));
  G.registerLazySingleton(() => SupabaseProgressPhotosDataSource(supabaseService: G()));
  G.registerLazySingleton(() => ProgressPhotosRepository(supabaseProgressPhotosDataSource: G()));
  G.registerLazySingleton(() => SupabasePremiumDataSource(supabaseService: G()));
  G.registerLazySingleton(() => PremiumRepository(supabasePremiumDataSource: G()));
  G.registerLazySingleton(() => SupabaseReminderDataSource(supabaseService: G()));
  G.registerLazySingleton(() => ReminderRepository(supabaseReminderDataSource: G()));
  G.registerLazySingleton(() => SupabaseExerciseDataSource(supabaseService: G()));
  G.registerLazySingleton(() => SupabaseWorkoutDataSource(supabaseService: G()));
  G.registerLazySingleton(() => SupabaseRoutineDataSource(supabaseService: G()));
  G.registerLazySingleton(() => WorkoutLocalDataSource(localStorageService: G()));
  G.registerLazySingleton(
    () => WorkoutRepository(supabaseExerciseDataSource: G(), supabaseWorkoutDataSource: G(), supabaseRoutineDataSource: G(), workoutLocalDataSource: G()),
  );
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
  G.registerFactory(() => HasSeenDietIntroUseCase(dietRepository: G()));
  G.registerFactory(() => MarkDietIntroSeenUseCase(dietRepository: G()));
  G.registerFactory(() => GetFavoriteFoodsUseCase(dietRepository: G()));
  G.registerFactory(() => GetRecentSearchesUseCase(dietRepository: G()));
  G.registerFactory(() => AddRecentSearchUseCase(dietRepository: G()));
  G.registerFactory(() => RemoveRecentSearchUseCase(dietRepository: G()));
  G.registerFactory(() => ClearRecentSearchesUseCase(dietRepository: G()));
  G.registerFactory(() => FavoriteFoodUseCase(dietRepository: G()));
  G.registerFactory(() => GetRecentlyLoggedFoodsUseCase(dietRepository: G()));
  G.registerFactory(() => UnfavoriteFoodUseCase(dietRepository: G()));
  G.registerFactory(() => CopyFoodLogsUseCase(dietRepository: G()));
  G.registerFactory(() => UploadFoodImageUseCase(dietRepository: G()));
  G.registerFactory(() => ScanNutritionLabelUseCase(dietRepository: G()));
  G.registerFactory(() => ScanMealUseCase(dietRepository: G()));
  G.registerFactory(() => LogScannedMealUseCase(dietRepository: G()));
  G.registerFactory(() => LogWaterUseCase(waterRepository: G()));
  G.registerFactory(() => GetDailyWaterUseCase(waterRepository: G()));
  G.registerFactory(() => GetWaterInRangeUseCase(waterRepository: G()));
  G.registerFactory(() => GetWaterGoalUseCase(waterRepository: G()));
  G.registerFactory(() => DeleteWaterLogUseCase(waterRepository: G()));
  G.registerFactory(() => LogBodyWeightUseCase(bodyWeightRepository: G()));
  G.registerFactory(() => GetRecentBodyWeightLogsUseCase(bodyWeightRepository: G()));
  G.registerFactory(() => GetBodyWeightInRangeUseCase(bodyWeightRepository: G()));
  G.registerFactory(() => DeleteBodyWeightLogUseCase(bodyWeightRepository: G()));
  G.registerFactory(() => GetLatestBodyWeightUseCase(bodyWeightRepository: G()));
  G.registerFactory(() => GetProgressPhotosUseCase(progressPhotosRepository: G()));
  G.registerFactory(() => AddProgressPhotoUseCase(progressPhotosRepository: G()));
  G.registerFactory(() => DeleteProgressPhotoUseCase(progressPhotosRepository: G()));
  G.registerFactory(() => LogSleepUseCase(sleepRepository: G()));
  G.registerFactory(() => GetRecentSleepLogsUseCase(sleepRepository: G()));
  G.registerFactory(() => GetSleepInRangeUseCase(sleepRepository: G()));
  G.registerFactory(() => GetSleepGoalUseCase(sleepRepository: G()));
  G.registerFactory(() => SaveSleepGoalUseCase(sleepRepository: G()));
  G.registerFactory(() => GetSleepLastSyncedUseCase(sleepRepository: G()));
  G.registerFactory(() => DeleteSleepLogUseCase(sleepRepository: G()));
  G.registerFactory(() => ImportSleepFromHealthUseCase(sleepRepository: G()));
  G.registerFactory(() => GetPremiumStatusUseCase(premiumRepository: G()));
  G.registerFactory(() => GetRemindersForDateUseCase(reminderRepository: G()));
  G.registerFactory(() => GetRemindersInRangeUseCase(reminderRepository: G()));
  G.registerFactory(() => CreateReminderUseCase(reminderRepository: G()));
  G.registerFactory(() => UpdateReminderUseCase(reminderRepository: G()));
  G.registerFactory(() => CompleteReminderUseCase(reminderRepository: G()));
  G.registerFactory(() => DeleteReminderUseCase(reminderRepository: G()));
  G.registerFactory(() => SearchExercisesUseCase(workoutRepository: G()));
  G.registerFactory(() => GetWorkoutsForDateUseCase(workoutRepository: G()));
  G.registerFactory(() => AddExerciseToWorkoutUseCase(workoutRepository: G()));
  G.registerFactory(() => RemoveWorkoutExerciseUseCase(workoutRepository: G()));
  G.registerFactory(() => LogSetUseCase(workoutRepository: G()));
  G.registerFactory(() => UpdateSetUseCase(workoutRepository: G()));
  G.registerFactory(() => DeleteSetUseCase(workoutRepository: G()));
  G.registerFactory(() => DeleteWorkoutUseCase(workoutRepository: G()));
  G.registerFactory(() => SetWorkoutExerciseCompletedUseCase(workoutRepository: G()));
  G.registerFactory(() => GetRoutinesUseCase(workoutRepository: G()));
  G.registerFactory(() => GetRoutineCycleUseCase(workoutRepository: G()));
  G.registerFactory(() => SaveRoutineUseCase(workoutRepository: G()));
  G.registerFactory(() => DeleteRoutineUseCase(workoutRepository: G()));
  G.registerFactory(() => ReorderRoutinesUseCase(workoutRepository: G()));
  G.registerFactory(() => StartWorkoutFromRoutineUseCase(workoutRepository: G()));
  G.registerFactory(() => GetLastSetsByExerciseUseCase(workoutRepository: G()));
  G.registerFactory(() => GetExerciseProgressionUseCase(workoutRepository: G()));
  G.registerFactory(() => GetLoggedExercisesUseCase(workoutRepository: G()));
  G.registerFactory(() => GetDailyWorkoutsInRangeUseCase(workoutRepository: G()));
  G.registerFactory(() => HasSeenWorkoutIntroUseCase(workoutRepository: G()));
  G.registerFactory(() => MarkWorkoutIntroSeenUseCase(workoutRepository: G()));
  G.registerFactory(() => GetBodyProfileUseCase(bodyProfileRepository: G()));
  G.registerFactory(() => SaveBodyProfileUseCase(bodyProfileRepository: G()));
  G.registerFactory(() => CompleteOnboardingUseCase(onboardingRepository: G()));
  G.registerFactory(() => HasSeenOnboardingUseCase(onboardingRepository: G()));
  G.registerFactory(() => GetUserUseCase(authRepository: G()));
  G.registerFactory(() => SignUpUseCase(authRepository: G()));
  G.registerFactory(() => SignInUseCase(authRepository: G()));
  G.registerFactory(() => SignOutUseCase(authRepository: G(), purchaseService: G()));
  G.registerFactory(() => UpdateProfileUseCase(authRepository: G()));
  G.registerFactory(() => UploadAvatarUseCase(authRepository: G()));
  G.registerFactory(() => DeleteAccountUseCase(authRepository: G(), purchaseService: G()));

  G.registerFactory(
    () => DietCubit(
      getDailyMacrosUseCase: G(),
      deleteFoodLogUseCase: G(),
      updateFoodLogUseCase: G(),
      getMacroGoalsUseCase: G(),
      getMacrosInRangeUseCase: G(),
      getAppSettingsUseCase: G(),
      hasSeenDietIntroUseCase: G(),
      markDietIntroSeenUseCase: G(),
    ),
  );
  G.registerFactory(() => DietHistoryCubit(getMacrosInRangeUseCase: G(), getMacroGoalsUseCase: G()));
  G.registerFactoryParam<CopyMealsCubit, DateTime, void>(
    (targetDate, _) => CopyMealsCubit(getMacrosInRangeUseCase: G(), getMacroGoalsUseCase: G(), copyFoodLogsUseCase: G(), targetDate: targetDate),
  );
  G.registerFactory(() => MacroGoalsCubit(getMacroGoalsUseCase: G(), saveMacroGoalsUseCase: G()));
  G.registerFactory(
    () => AddFoodCubit(
      searchFoodsUseCase: G(),
      logFoodUseCase: G(),
      getAppSettingsUseCase: G(),
      getFavoriteFoodsUseCase: G(),
      favoriteFoodUseCase: G(),
      unfavoriteFoodUseCase: G(),
      getRecentSearchesUseCase: G(),
      addRecentSearchUseCase: G(),
      removeRecentSearchUseCase: G(),
      clearRecentSearchesUseCase: G(),
      getRecentlyLoggedFoodsUseCase: G(),
    ),
  );
  G.registerFactory(() => CustomFoodCubit(uploadFoodImageUseCase: G(), scanNutritionLabelUseCase: G(), imagePickerService: G()));
  G.registerFactoryParam<MealScanCubit, DateTime, void>(
    (loggedDate, _) => MealScanCubit(scanMealUseCase: G(), logScannedMealUseCase: G(), imagePickerService: G(), loggedDate: loggedDate),
  );
  G.registerFactory(() => RecipesCubit(getRecipesUseCase: G(), deleteRecipeUseCase: G(), logFoodUseCase: G(), getAppSettingsUseCase: G()));
  G.registerFactoryParam<RecipeFormCubit, Recipe?, void>(
    (recipe, _) => RecipeFormCubit(saveRecipeUseCase: G(), getAppSettingsUseCase: G(), uploadFoodImageUseCase: G(), imagePickerService: G(), recipe: recipe),
  );
  G.registerFactory(
    () => WorkoutCubit(
      getWorkoutsForDateUseCase: G(),
      addExerciseToWorkoutUseCase: G(),
      removeWorkoutExerciseUseCase: G(),
      logSetUseCase: G(),
      updateSetUseCase: G(),
      deleteSetUseCase: G(),
      deleteWorkoutUseCase: G(),
      setWorkoutExerciseCompletedUseCase: G(),
      getRoutineCycleUseCase: G(),
      startWorkoutFromRoutineUseCase: G(),
      getLastSetsByExerciseUseCase: G(),
      getLatestBodyWeightUseCase: G(),
      getAppSettingsUseCase: G(),
      hasSeenWorkoutIntroUseCase: G(),
      markWorkoutIntroSeenUseCase: G(),
    ),
  );
  G.registerFactory(() => ExerciseSearchCubit(searchExercisesUseCase: G()));
  G.registerFactoryParam<ExerciseProgressionCubit, Exercise, void>(
    (exercise, _) => ExerciseProgressionCubit(getExerciseProgressionUseCase: G(), getAppSettingsUseCase: G(), exercise: exercise),
  );
  G.registerFactory(() => ExerciseProgressionListCubit(getLoggedExercisesUseCase: G()));
  G.registerFactory(() => WorkoutHistoryCubit(getDailyWorkoutsInRangeUseCase: G(), getAppSettingsUseCase: G()));
  G.registerFactory(() => RoutinesCubit(getRoutinesUseCase: G(), deleteRoutineUseCase: G(), reorderRoutinesUseCase: G()));
  G.registerFactoryParam<RoutineFormCubit, Routine?, void>((routine, _) => RoutineFormCubit(saveRoutineUseCase: G(), routine: routine));
  G.registerFactory(
    () => HomeCubit(
      getUserUseCase: G(),
      getMacroGoalsUseCase: G(),
      getDailyMacrosUseCase: G(),
      getDailyWaterUseCase: G(),
      getWaterGoalUseCase: G(),
      getRemindersInRangeUseCase: G(),
      getWorkoutsForDateUseCase: G(),
      getRecentSleepLogsUseCase: G(),
      getLatestBodyWeightUseCase: G(),
      getAppSettingsUseCase: G(),
    ),
  );
  G.registerFactory(
    () => OnboardingCubit(
      completeOnboardingUseCase: G(),
      saveMacroGoalsUseCase: G(),
      logBodyWeightUseCase: G(),
      saveBodyProfileUseCase: G(),
      getAppSettingsUseCase: G(),
    ),
  );
  G.registerFactory(
    () => ObjectiveCubit(
      getBodyProfileUseCase: G(),
      saveBodyProfileUseCase: G(),
      getLatestBodyWeightUseCase: G(),
      saveMacroGoalsUseCase: G(),
      getAppSettingsUseCase: G(),
    ),
  );
  G.registerFactory(
    () => AuthCubit(
      getUserUseCase: G(),
      signUpUseCase: G(),
      signInUseCase: G(),
      signOutUseCase: G(),
      updateProfileUseCase: G(),
      uploadAvatarUseCase: G(),
      deleteAccountUseCase: G(),
      imagePickerService: G(),
    ),
  );
  G.registerFactory(
    () => WaterCubit(getDailyWaterUseCase: G(), logWaterUseCase: G(), deleteWaterLogUseCase: G(), waterLocalDataSource: G(), getAppSettingsUseCase: G()),
  );
  G.registerFactory(() => WaterHistoryCubit(getWaterInRangeUseCase: G(), getWaterGoalUseCase: G()));
  G.registerFactory(
    () => ReminderCubit(
      getRemindersForDateUseCase: G(),
      createReminderUseCase: G(),
      updateReminderUseCase: G(),
      completeReminderUseCase: G(),
      deleteReminderUseCase: G(),
      notificationService: G(),
    ),
  );
  G.registerFactory(() => ReminderHistoryCubit(getRemindersInRangeUseCase: G()));
  G.registerFactory(
    () => BodyWeightCubit(getRecentBodyWeightLogsUseCase: G(), logBodyWeightUseCase: G(), deleteBodyWeightLogUseCase: G(), getAppSettingsUseCase: G()),
  );
  G.registerFactory(() => BodyWeightHistoryCubit(getBodyWeightInRangeUseCase: G(), getAppSettingsUseCase: G()));
  G.registerFactory(
    () => ProgressPhotosCubit(getProgressPhotosUseCase: G(), addProgressPhotoUseCase: G(), deleteProgressPhotoUseCase: G(), imagePickerService: G()),
  );
  G.registerFactory(() => SleepHistoryCubit(getSleepInRangeUseCase: G(), getSleepGoalUseCase: G()));
  G.registerFactory(
    () => SleepCubit(
      getRecentSleepLogsUseCase: G(),
      logSleepUseCase: G(),
      deleteSleepLogUseCase: G(),
      getSleepGoalUseCase: G(),
      saveSleepGoalUseCase: G(),
      getSleepLastSyncedUseCase: G(),
      importSleepFromHealthUseCase: G(),
      healthService: G(),
    ),
  );
}
