import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_cubit.dart';
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

import '../mocks/datasources_mocks.dart';
import '../mocks/services_mocks.dart';
import '../mocks/use_cases_mocks.dart';

abstract class CubitsFactories {
  static AppCubit buildAppCubit({MockGetAppSettingsUseCase? getAppSettingsUseCase, MockSaveAppSettingsUseCase? saveAppSettingsUseCase}) => AppCubit(
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
    saveAppSettingsUseCase: saveAppSettingsUseCase ?? MockSaveAppSettingsUseCase(),
  );

  static AuthCubit buildAuthCubit({
    MockGetUserUseCase? getUserUseCase,
    MockSignUpUseCase? signUpUseCase,
    MockSignInUseCase? signInUseCase,
    MockSignOutUseCase? signOutUseCase,
    MockUpdateProfileUseCase? updateProfileUseCase,
    MockUploadAvatarUseCase? uploadAvatarUseCase,
    MockDeleteAccountUseCase? deleteAccountUseCase,
    MockImagePickerService? imagePickerService,
    MockAnalyticsService? analyticsService,
  }) => AuthCubit(
    getUserUseCase: getUserUseCase ?? MockGetUserUseCase(),
    signUpUseCase: signUpUseCase ?? MockSignUpUseCase(),
    signInUseCase: signInUseCase ?? MockSignInUseCase(),
    signOutUseCase: signOutUseCase ?? MockSignOutUseCase(),
    updateProfileUseCase: updateProfileUseCase ?? MockUpdateProfileUseCase(),
    uploadAvatarUseCase: uploadAvatarUseCase ?? MockUploadAvatarUseCase(),
    deleteAccountUseCase: deleteAccountUseCase ?? MockDeleteAccountUseCase(),
    imagePickerService: imagePickerService ?? MockImagePickerService(),
    analyticsService: analyticsService ?? MockAnalyticsService(),
  );

  static HomeCubit buildHomeCubit({
    MockGetUserUseCase? getUserUseCase,
    MockGetMacroGoalsUseCase? getMacroGoalsUseCase,
    MockGetDailyMacrosUseCase? getDailyMacrosUseCase,
    MockGetDailyWaterUseCase? getDailyWaterUseCase,
    MockGetWaterGoalUseCase? getWaterGoalUseCase,
    MockGetRemindersInRangeUseCase? getRemindersInRangeUseCase,
    MockGetWorkoutsForDateUseCase? getWorkoutsForDateUseCase,
    MockGetRecentSleepLogsUseCase? getRecentSleepLogsUseCase,
    MockGetSleepGoalUseCase? getSleepGoalUseCase,
    MockGetLatestBodyWeightUseCase? getLatestBodyWeightUseCase,
    MockGetRecentBodyWeightLogsUseCase? getRecentBodyWeightLogsUseCase,
    MockGetHomeLayoutUseCase? getHomeLayoutUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => HomeCubit(
    getUserUseCase: getUserUseCase ?? MockGetUserUseCase(),
    getMacroGoalsUseCase: getMacroGoalsUseCase ?? MockGetMacroGoalsUseCase(),
    getDailyMacrosUseCase: getDailyMacrosUseCase ?? MockGetDailyMacrosUseCase(),
    getDailyWaterUseCase: getDailyWaterUseCase ?? MockGetDailyWaterUseCase(),
    getWaterGoalUseCase: getWaterGoalUseCase ?? MockGetWaterGoalUseCase(),
    getRemindersInRangeUseCase: getRemindersInRangeUseCase ?? MockGetRemindersInRangeUseCase(),
    getWorkoutsForDateUseCase: getWorkoutsForDateUseCase ?? MockGetWorkoutsForDateUseCase(),
    getRecentSleepLogsUseCase: getRecentSleepLogsUseCase ?? MockGetRecentSleepLogsUseCase(),
    getSleepGoalUseCase: getSleepGoalUseCase ?? MockGetSleepGoalUseCase(),
    getLatestBodyWeightUseCase: getLatestBodyWeightUseCase ?? MockGetLatestBodyWeightUseCase(),
    getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase ?? MockGetRecentBodyWeightLogsUseCase(),
    getHomeLayoutUseCase: getHomeLayoutUseCase ?? MockGetHomeLayoutUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static DietCubit buildDietCubit({
    MockGetDailyMacrosUseCase? getDailyMacrosUseCase,
    MockDeleteFoodLogUseCase? deleteFoodLogUseCase,
    MockUpdateFoodLogUseCase? updateFoodLogUseCase,
    MockGetMacroGoalsUseCase? getMacroGoalsUseCase,
    MockGetMacrosInRangeUseCase? getMacrosInRangeUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
    MockHasSeenDietIntroUseCase? hasSeenDietIntroUseCase,
    MockMarkDietIntroSeenUseCase? markDietIntroSeenUseCase,
  }) => DietCubit(
    getDailyMacrosUseCase: getDailyMacrosUseCase ?? MockGetDailyMacrosUseCase(),
    deleteFoodLogUseCase: deleteFoodLogUseCase ?? MockDeleteFoodLogUseCase(),
    updateFoodLogUseCase: updateFoodLogUseCase ?? MockUpdateFoodLogUseCase(),
    getMacroGoalsUseCase: getMacroGoalsUseCase ?? MockGetMacroGoalsUseCase(),
    getMacrosInRangeUseCase: getMacrosInRangeUseCase ?? MockGetMacrosInRangeUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
    hasSeenDietIntroUseCase: hasSeenDietIntroUseCase ?? MockHasSeenDietIntroUseCase(),
    markDietIntroSeenUseCase: markDietIntroSeenUseCase ?? MockMarkDietIntroSeenUseCase(),
  );

  static DietHistoryCubit buildDietHistoryCubit({MockGetMacrosInRangeUseCase? getMacrosInRangeUseCase, MockGetMacroGoalsUseCase? getMacroGoalsUseCase}) =>
      DietHistoryCubit(
        getMacrosInRangeUseCase: getMacrosInRangeUseCase ?? MockGetMacrosInRangeUseCase(),
        getMacroGoalsUseCase: getMacroGoalsUseCase ?? MockGetMacroGoalsUseCase(),
      );

  static CopyMealsCubit buildCopyMealsCubit({
    MockGetMacrosInRangeUseCase? getMacrosInRangeUseCase,
    MockGetMacroGoalsUseCase? getMacroGoalsUseCase,
    MockCopyFoodLogsUseCase? copyFoodLogsUseCase,
    DateTime? targetDate,
  }) => CopyMealsCubit(
    getMacrosInRangeUseCase: getMacrosInRangeUseCase ?? MockGetMacrosInRangeUseCase(),
    getMacroGoalsUseCase: getMacroGoalsUseCase ?? MockGetMacroGoalsUseCase(),
    copyFoodLogsUseCase: copyFoodLogsUseCase ?? MockCopyFoodLogsUseCase(),
    targetDate: targetDate ?? DateTime(2026, 7, 14),
  );

  static MacroGoalsCubit buildMacroGoalsCubit({MockGetMacroGoalsUseCase? getMacroGoalsUseCase, MockSaveMacroGoalsUseCase? saveMacroGoalsUseCase}) =>
      MacroGoalsCubit(
        getMacroGoalsUseCase: getMacroGoalsUseCase ?? MockGetMacroGoalsUseCase(),
        saveMacroGoalsUseCase: saveMacroGoalsUseCase ?? MockSaveMacroGoalsUseCase(),
      );

  static AddFoodCubit buildAddFoodCubit({
    MockSearchFoodsUseCase? searchFoodsUseCase,
    MockLogFoodUseCase? logFoodUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
    MockGetFavoriteFoodsUseCase? getFavoriteFoodsUseCase,
    MockFavoriteFoodUseCase? favoriteFoodUseCase,
    MockUnfavoriteFoodUseCase? unfavoriteFoodUseCase,
    MockGetRecentSearchesUseCase? getRecentSearchesUseCase,
    MockAddRecentSearchUseCase? addRecentSearchUseCase,
    MockRemoveRecentSearchUseCase? removeRecentSearchUseCase,
    MockClearRecentSearchesUseCase? clearRecentSearchesUseCase,
    MockGetRecentlyLoggedFoodsUseCase? getRecentlyLoggedFoodsUseCase,
  }) => AddFoodCubit(
    searchFoodsUseCase: searchFoodsUseCase ?? MockSearchFoodsUseCase(),
    logFoodUseCase: logFoodUseCase ?? MockLogFoodUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
    getFavoriteFoodsUseCase: getFavoriteFoodsUseCase ?? MockGetFavoriteFoodsUseCase(),
    favoriteFoodUseCase: favoriteFoodUseCase ?? MockFavoriteFoodUseCase(),
    unfavoriteFoodUseCase: unfavoriteFoodUseCase ?? MockUnfavoriteFoodUseCase(),
    getRecentSearchesUseCase: getRecentSearchesUseCase ?? MockGetRecentSearchesUseCase(),
    addRecentSearchUseCase: addRecentSearchUseCase ?? MockAddRecentSearchUseCase(),
    removeRecentSearchUseCase: removeRecentSearchUseCase ?? MockRemoveRecentSearchUseCase(),
    clearRecentSearchesUseCase: clearRecentSearchesUseCase ?? MockClearRecentSearchesUseCase(),
    getRecentlyLoggedFoodsUseCase: getRecentlyLoggedFoodsUseCase ?? MockGetRecentlyLoggedFoodsUseCase(),
  );

  static CustomFoodCubit buildCustomFoodCubit({
    MockUploadFoodImageUseCase? uploadFoodImageUseCase,
    MockScanNutritionLabelUseCase? scanNutritionLabelUseCase,
    MockImagePickerService? imagePickerService,
  }) => CustomFoodCubit(
    uploadFoodImageUseCase: uploadFoodImageUseCase ?? MockUploadFoodImageUseCase(),
    scanNutritionLabelUseCase: scanNutritionLabelUseCase ?? MockScanNutritionLabelUseCase(),
    imagePickerService: imagePickerService ?? MockImagePickerService(),
  );

  static MealScanCubit buildMealScanCubit({
    MockScanMealUseCase? scanMealUseCase,
    MockLogScannedMealUseCase? logScannedMealUseCase,
    MockImagePickerService? imagePickerService,
    DateTime? loggedDate,
  }) => MealScanCubit(
    scanMealUseCase: scanMealUseCase ?? MockScanMealUseCase(),
    logScannedMealUseCase: logScannedMealUseCase ?? MockLogScannedMealUseCase(),
    imagePickerService: imagePickerService ?? MockImagePickerService(),
    loggedDate: loggedDate ?? DateTime(2026, 7, 19),
  );

  static RecipesCubit buildRecipesCubit({
    MockGetRecipesUseCase? getRecipesUseCase,
    MockDeleteRecipeUseCase? deleteRecipeUseCase,
    MockLogFoodUseCase? logFoodUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => RecipesCubit(
    getRecipesUseCase: getRecipesUseCase ?? MockGetRecipesUseCase(),
    deleteRecipeUseCase: deleteRecipeUseCase ?? MockDeleteRecipeUseCase(),
    logFoodUseCase: logFoodUseCase ?? MockLogFoodUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static RecipeFormCubit buildRecipeFormCubit({
    MockSaveRecipeUseCase? saveRecipeUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
    MockUploadFoodImageUseCase? uploadFoodImageUseCase,
    MockImagePickerService? imagePickerService,
    Recipe? recipe,
  }) => RecipeFormCubit(
    saveRecipeUseCase: saveRecipeUseCase ?? MockSaveRecipeUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
    uploadFoodImageUseCase: uploadFoodImageUseCase ?? MockUploadFoodImageUseCase(),
    imagePickerService: imagePickerService ?? MockImagePickerService(),
    recipe: recipe,
  );

  static OnboardingCubit buildOnboardingCubit({
    MockCompleteOnboardingUseCase? completeOnboardingUseCase,
    MockSaveMacroGoalsUseCase? saveMacroGoalsUseCase,
    MockLogBodyWeightUseCase? logBodyWeightUseCase,
    MockSaveBodyProfileUseCase? saveBodyProfileUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => OnboardingCubit(
    completeOnboardingUseCase: completeOnboardingUseCase ?? MockCompleteOnboardingUseCase(),
    saveMacroGoalsUseCase: saveMacroGoalsUseCase ?? MockSaveMacroGoalsUseCase(),
    logBodyWeightUseCase: logBodyWeightUseCase ?? MockLogBodyWeightUseCase(),
    saveBodyProfileUseCase: saveBodyProfileUseCase ?? MockSaveBodyProfileUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static ObjectiveCubit buildObjectiveCubit({
    MockGetBodyProfileUseCase? getBodyProfileUseCase,
    MockSaveBodyProfileUseCase? saveBodyProfileUseCase,
    MockGetLatestBodyWeightUseCase? getLatestBodyWeightUseCase,
    MockSaveMacroGoalsUseCase? saveMacroGoalsUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => ObjectiveCubit(
    getBodyProfileUseCase: getBodyProfileUseCase ?? MockGetBodyProfileUseCase(),
    saveBodyProfileUseCase: saveBodyProfileUseCase ?? MockSaveBodyProfileUseCase(),
    getLatestBodyWeightUseCase: getLatestBodyWeightUseCase ?? MockGetLatestBodyWeightUseCase(),
    saveMacroGoalsUseCase: saveMacroGoalsUseCase ?? MockSaveMacroGoalsUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static WaterCubit buildWaterCubit({
    MockGetDailyWaterUseCase? getDailyWaterUseCase,
    MockLogWaterUseCase? logWaterUseCase,
    MockDeleteWaterLogUseCase? deleteWaterLogUseCase,
    MockWaterLocalDataSource? waterLocalDataSource,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => WaterCubit(
    getDailyWaterUseCase: getDailyWaterUseCase ?? MockGetDailyWaterUseCase(),
    logWaterUseCase: logWaterUseCase ?? MockLogWaterUseCase(),
    deleteWaterLogUseCase: deleteWaterLogUseCase ?? MockDeleteWaterLogUseCase(),
    waterLocalDataSource: waterLocalDataSource ?? MockWaterLocalDataSource(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static WaterHistoryCubit buildWaterHistoryCubit({MockGetWaterInRangeUseCase? getWaterInRangeUseCase, MockGetWaterGoalUseCase? getWaterGoalUseCase}) =>
      WaterHistoryCubit(
        getWaterInRangeUseCase: getWaterInRangeUseCase ?? MockGetWaterInRangeUseCase(),
        getWaterGoalUseCase: getWaterGoalUseCase ?? MockGetWaterGoalUseCase(),
      );

  static SleepHistoryCubit buildSleepHistoryCubit({MockGetSleepInRangeUseCase? getSleepInRangeUseCase, MockGetSleepGoalUseCase? getSleepGoalUseCase}) =>
      SleepHistoryCubit(
        getSleepInRangeUseCase: getSleepInRangeUseCase ?? MockGetSleepInRangeUseCase(),
        getSleepGoalUseCase: getSleepGoalUseCase ?? MockGetSleepGoalUseCase(),
      );

  static BodyWeightCubit buildBodyWeightCubit({
    MockGetRecentBodyWeightLogsUseCase? getRecentBodyWeightLogsUseCase,
    MockLogBodyWeightUseCase? logBodyWeightUseCase,
    MockDeleteBodyWeightLogUseCase? deleteBodyWeightLogUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => BodyWeightCubit(
    getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase ?? MockGetRecentBodyWeightLogsUseCase(),
    logBodyWeightUseCase: logBodyWeightUseCase ?? MockLogBodyWeightUseCase(),
    deleteBodyWeightLogUseCase: deleteBodyWeightLogUseCase ?? MockDeleteBodyWeightLogUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static ProgressPhotosCubit buildProgressPhotosCubit({
    MockGetProgressPhotosUseCase? getProgressPhotosUseCase,
    MockAddProgressPhotoUseCase? addProgressPhotoUseCase,
    MockDeleteProgressPhotoUseCase? deleteProgressPhotoUseCase,
    MockImagePickerService? imagePickerService,
  }) => ProgressPhotosCubit(
    getProgressPhotosUseCase: getProgressPhotosUseCase ?? MockGetProgressPhotosUseCase(),
    addProgressPhotoUseCase: addProgressPhotoUseCase ?? MockAddProgressPhotoUseCase(),
    deleteProgressPhotoUseCase: deleteProgressPhotoUseCase ?? MockDeleteProgressPhotoUseCase(),
    imagePickerService: imagePickerService ?? MockImagePickerService(),
  );

  static BodyWeightHistoryCubit buildBodyWeightHistoryCubit({
    MockGetBodyWeightInRangeUseCase? getBodyWeightInRangeUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => BodyWeightHistoryCubit(
    getBodyWeightInRangeUseCase: getBodyWeightInRangeUseCase ?? MockGetBodyWeightInRangeUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static SleepCubit buildSleepCubit({
    MockGetRecentSleepLogsUseCase? getRecentSleepLogsUseCase,
    MockLogSleepUseCase? logSleepUseCase,
    MockDeleteSleepLogUseCase? deleteSleepLogUseCase,
    MockGetSleepGoalUseCase? getSleepGoalUseCase,
    MockSaveSleepGoalUseCase? saveSleepGoalUseCase,
    MockGetSleepLastSyncedUseCase? getSleepLastSyncedUseCase,
    MockImportSleepFromHealthUseCase? importSleepFromHealthUseCase,
    MockHealthService? healthService,
  }) => SleepCubit(
    getRecentSleepLogsUseCase: getRecentSleepLogsUseCase ?? MockGetRecentSleepLogsUseCase(),
    logSleepUseCase: logSleepUseCase ?? MockLogSleepUseCase(),
    deleteSleepLogUseCase: deleteSleepLogUseCase ?? MockDeleteSleepLogUseCase(),
    getSleepGoalUseCase: getSleepGoalUseCase ?? MockGetSleepGoalUseCase(),
    saveSleepGoalUseCase: saveSleepGoalUseCase ?? MockSaveSleepGoalUseCase(),
    getSleepLastSyncedUseCase: getSleepLastSyncedUseCase ?? MockGetSleepLastSyncedUseCase(),
    importSleepFromHealthUseCase: importSleepFromHealthUseCase ?? MockImportSleepFromHealthUseCase(),
    healthService: healthService ?? MockHealthService(),
  );

  static WorkoutCubit buildWorkoutCubit({
    MockGetWorkoutsForDateUseCase? getWorkoutsForDateUseCase,
    MockAddExerciseToWorkoutUseCase? addExerciseToWorkoutUseCase,
    MockRemoveWorkoutExerciseUseCase? removeWorkoutExerciseUseCase,
    MockLogSetUseCase? logSetUseCase,
    MockUpdateSetUseCase? updateSetUseCase,
    MockDeleteSetUseCase? deleteSetUseCase,
    MockDeleteWorkoutUseCase? deleteWorkoutUseCase,
    MockSetWorkoutExerciseCompletedUseCase? setWorkoutExerciseCompletedUseCase,
    MockGetRoutineCycleUseCase? getRoutineCycleUseCase,
    MockStartWorkoutFromRoutineUseCase? startWorkoutFromRoutineUseCase,
    MockGetLastSetsByExerciseUseCase? getLastSetsByExerciseUseCase,
    MockGetLatestBodyWeightUseCase? getLatestBodyWeightUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
    MockHasSeenWorkoutIntroUseCase? hasSeenWorkoutIntroUseCase,
    MockMarkWorkoutIntroSeenUseCase? markWorkoutIntroSeenUseCase,
  }) => WorkoutCubit(
    getWorkoutsForDateUseCase: getWorkoutsForDateUseCase ?? MockGetWorkoutsForDateUseCase(),
    addExerciseToWorkoutUseCase: addExerciseToWorkoutUseCase ?? MockAddExerciseToWorkoutUseCase(),
    removeWorkoutExerciseUseCase: removeWorkoutExerciseUseCase ?? MockRemoveWorkoutExerciseUseCase(),
    logSetUseCase: logSetUseCase ?? MockLogSetUseCase(),
    updateSetUseCase: updateSetUseCase ?? MockUpdateSetUseCase(),
    deleteSetUseCase: deleteSetUseCase ?? MockDeleteSetUseCase(),
    deleteWorkoutUseCase: deleteWorkoutUseCase ?? MockDeleteWorkoutUseCase(),
    setWorkoutExerciseCompletedUseCase: setWorkoutExerciseCompletedUseCase ?? MockSetWorkoutExerciseCompletedUseCase(),
    getRoutineCycleUseCase: getRoutineCycleUseCase ?? MockGetRoutineCycleUseCase(),
    startWorkoutFromRoutineUseCase: startWorkoutFromRoutineUseCase ?? MockStartWorkoutFromRoutineUseCase(),
    getLastSetsByExerciseUseCase: getLastSetsByExerciseUseCase ?? MockGetLastSetsByExerciseUseCase(),
    getLatestBodyWeightUseCase: getLatestBodyWeightUseCase ?? MockGetLatestBodyWeightUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
    hasSeenWorkoutIntroUseCase: hasSeenWorkoutIntroUseCase ?? MockHasSeenWorkoutIntroUseCase(),
    markWorkoutIntroSeenUseCase: markWorkoutIntroSeenUseCase ?? MockMarkWorkoutIntroSeenUseCase(),
  );

  static ExerciseSearchCubit buildExerciseSearchCubit({MockSearchExercisesUseCase? searchExercisesUseCase}) =>
      ExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase ?? MockSearchExercisesUseCase());

  static RoutinesCubit buildRoutinesCubit({
    MockGetRoutinesUseCase? getRoutinesUseCase,
    MockDeleteRoutineUseCase? deleteRoutineUseCase,
    MockReorderRoutinesUseCase? reorderRoutinesUseCase,
  }) => RoutinesCubit(
    getRoutinesUseCase: getRoutinesUseCase ?? MockGetRoutinesUseCase(),
    deleteRoutineUseCase: deleteRoutineUseCase ?? MockDeleteRoutineUseCase(),
    reorderRoutinesUseCase: reorderRoutinesUseCase ?? MockReorderRoutinesUseCase(),
  );

  static RoutineFormCubit buildRoutineFormCubit({MockSaveRoutineUseCase? saveRoutineUseCase, Routine? routine}) =>
      RoutineFormCubit(saveRoutineUseCase: saveRoutineUseCase ?? MockSaveRoutineUseCase(), routine: routine);

  static ReminderCubit buildReminderCubit({
    MockGetRemindersForDateUseCase? getRemindersForDateUseCase,
    MockCreateReminderUseCase? createReminderUseCase,
    MockUpdateReminderUseCase? updateReminderUseCase,
    MockCompleteReminderUseCase? completeReminderUseCase,
    MockDeleteReminderUseCase? deleteReminderUseCase,
    MockNotificationService? notificationService,
  }) => ReminderCubit(
    getRemindersForDateUseCase: getRemindersForDateUseCase ?? MockGetRemindersForDateUseCase(),
    createReminderUseCase: createReminderUseCase ?? MockCreateReminderUseCase(),
    updateReminderUseCase: updateReminderUseCase ?? MockUpdateReminderUseCase(),
    completeReminderUseCase: completeReminderUseCase ?? MockCompleteReminderUseCase(),
    deleteReminderUseCase: deleteReminderUseCase ?? MockDeleteReminderUseCase(),
    notificationService: notificationService ?? MockNotificationService(),
  );

  static ReminderHistoryCubit buildReminderHistoryCubit({MockGetRemindersInRangeUseCase? getRemindersInRangeUseCase}) =>
      ReminderHistoryCubit(getRemindersInRangeUseCase: getRemindersInRangeUseCase ?? MockGetRemindersInRangeUseCase());

  static HomeLayoutCubit buildHomeLayoutCubit({MockGetHomeLayoutUseCase? getHomeLayoutUseCase, MockSaveHomeLayoutUseCase? saveHomeLayoutUseCase}) =>
      HomeLayoutCubit(
        getHomeLayoutUseCase: getHomeLayoutUseCase ?? MockGetHomeLayoutUseCase(),
        saveHomeLayoutUseCase: saveHomeLayoutUseCase ?? MockSaveHomeLayoutUseCase(),
      );
}
