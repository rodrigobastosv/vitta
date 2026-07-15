import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_cubit.dart';
import 'package:vitta/app/presentation/pages/workout/workout_cubit.dart';

import '../mocks/datasources_mocks.dart';
import '../mocks/services_mocks.dart';
import '../mocks/use_cases_mocks.dart';

abstract class CubitsFactories {
  static AppCubit buildAppCubit({MockGetAppSettingsUseCase? getAppSettingsUseCase, MockSaveAppSettingsUseCase? saveAppSettingsUseCase}) =>
      AppCubit(
        getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
        saveAppSettingsUseCase: saveAppSettingsUseCase ?? MockSaveAppSettingsUseCase(),
      );

  static AuthCubit buildAuthCubit({
    MockGetUserUseCase? getUserUseCase,
    MockSignUpUseCase? signUpUseCase,
    MockSignInUseCase? signInUseCase,
    MockSignOutUseCase? signOutUseCase,
  }) => AuthCubit(
    getUserUseCase: getUserUseCase ?? MockGetUserUseCase(),
    signUpUseCase: signUpUseCase ?? MockSignUpUseCase(),
    signInUseCase: signInUseCase ?? MockSignInUseCase(),
    signOutUseCase: signOutUseCase ?? MockSignOutUseCase(),
  );

  static DietCubit buildDietCubit({
    MockGetDailyMacrosUseCase? getDailyMacrosUseCase,
    MockDeleteFoodLogUseCase? deleteFoodLogUseCase,
    MockUpdateFoodLogUseCase? updateFoodLogUseCase,
    MockGetMacroGoalsUseCase? getMacroGoalsUseCase,
    MockGetMacrosInRangeUseCase? getMacrosInRangeUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => DietCubit(
    getDailyMacrosUseCase: getDailyMacrosUseCase ?? MockGetDailyMacrosUseCase(),
    deleteFoodLogUseCase: deleteFoodLogUseCase ?? MockDeleteFoodLogUseCase(),
    updateFoodLogUseCase: updateFoodLogUseCase ?? MockUpdateFoodLogUseCase(),
    getMacroGoalsUseCase: getMacroGoalsUseCase ?? MockGetMacroGoalsUseCase(),
    getMacrosInRangeUseCase: getMacrosInRangeUseCase ?? MockGetMacrosInRangeUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static DietHistoryCubit buildDietHistoryCubit({
    MockGetMacrosInRangeUseCase? getMacrosInRangeUseCase,
    MockGetMacroGoalsUseCase? getMacroGoalsUseCase,
  }) => DietHistoryCubit(
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

  static MacroGoalsCubit buildMacroGoalsCubit({
    MockGetMacroGoalsUseCase? getMacroGoalsUseCase,
    MockSaveMacroGoalsUseCase? saveMacroGoalsUseCase,
  }) => MacroGoalsCubit(
    getMacroGoalsUseCase: getMacroGoalsUseCase ?? MockGetMacroGoalsUseCase(),
    saveMacroGoalsUseCase: saveMacroGoalsUseCase ?? MockSaveMacroGoalsUseCase(),
  );

  static FoodSearchCubit buildFoodSearchCubit({
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
  }) => FoodSearchCubit(
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

  static RecipesCubit buildRecipesCubit({MockGetRecipesUseCase? getRecipesUseCase, MockDeleteRecipeUseCase? deleteRecipeUseCase}) =>
      RecipesCubit(
        getRecipesUseCase: getRecipesUseCase ?? MockGetRecipesUseCase(),
        deleteRecipeUseCase: deleteRecipeUseCase ?? MockDeleteRecipeUseCase(),
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

  static OnboardingCubit buildOnboardingCubit({MockCompleteOnboardingUseCase? completeOnboardingUseCase}) =>
      OnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase ?? MockCompleteOnboardingUseCase());

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

  static WaterHistoryCubit buildWaterHistoryCubit({
    MockGetWaterInRangeUseCase? getWaterInRangeUseCase,
    MockGetWaterGoalUseCase? getWaterGoalUseCase,
  }) => WaterHistoryCubit(
    getWaterInRangeUseCase: getWaterInRangeUseCase ?? MockGetWaterInRangeUseCase(),
    getWaterGoalUseCase: getWaterGoalUseCase ?? MockGetWaterGoalUseCase(),
  );

  static SleepHistoryCubit buildSleepHistoryCubit({
    MockGetSleepInRangeUseCase? getSleepInRangeUseCase,
    MockGetSleepGoalUseCase? getSleepGoalUseCase,
  }) => SleepHistoryCubit(
    getSleepInRangeUseCase: getSleepInRangeUseCase ?? MockGetSleepInRangeUseCase(),
    getSleepGoalUseCase: getSleepGoalUseCase ?? MockGetSleepGoalUseCase(),
  );

  static SleepCubit buildSleepCubit({
    MockGetRecentSleepLogsUseCase? getRecentSleepLogsUseCase,
    MockLogSleepUseCase? logSleepUseCase,
    MockDeleteSleepLogUseCase? deleteSleepLogUseCase,
    MockGetSleepGoalUseCase? getSleepGoalUseCase,
    MockSaveSleepGoalUseCase? saveSleepGoalUseCase,
  }) => SleepCubit(
    getRecentSleepLogsUseCase: getRecentSleepLogsUseCase ?? MockGetRecentSleepLogsUseCase(),
    logSleepUseCase: logSleepUseCase ?? MockLogSleepUseCase(),
    deleteSleepLogUseCase: deleteSleepLogUseCase ?? MockDeleteSleepLogUseCase(),
    getSleepGoalUseCase: getSleepGoalUseCase ?? MockGetSleepGoalUseCase(),
    saveSleepGoalUseCase: saveSleepGoalUseCase ?? MockSaveSleepGoalUseCase(),
  );

  static WorkoutCubit buildWorkoutCubit({
    MockGetWorkoutsForDateUseCase? getWorkoutsForDateUseCase,
    MockAddExerciseToWorkoutUseCase? addExerciseToWorkoutUseCase,
    MockRemoveWorkoutExerciseUseCase? removeWorkoutExerciseUseCase,
    MockLogSetUseCase? logSetUseCase,
    MockUpdateSetUseCase? updateSetUseCase,
    MockDeleteSetUseCase? deleteSetUseCase,
    MockDeleteWorkoutUseCase? deleteWorkoutUseCase,
    MockGetAppSettingsUseCase? getAppSettingsUseCase,
  }) => WorkoutCubit(
    getWorkoutsForDateUseCase: getWorkoutsForDateUseCase ?? MockGetWorkoutsForDateUseCase(),
    addExerciseToWorkoutUseCase: addExerciseToWorkoutUseCase ?? MockAddExerciseToWorkoutUseCase(),
    removeWorkoutExerciseUseCase: removeWorkoutExerciseUseCase ?? MockRemoveWorkoutExerciseUseCase(),
    logSetUseCase: logSetUseCase ?? MockLogSetUseCase(),
    updateSetUseCase: updateSetUseCase ?? MockUpdateSetUseCase(),
    deleteSetUseCase: deleteSetUseCase ?? MockDeleteSetUseCase(),
    deleteWorkoutUseCase: deleteWorkoutUseCase ?? MockDeleteWorkoutUseCase(),
    getAppSettingsUseCase: getAppSettingsUseCase ?? MockGetAppSettingsUseCase(),
  );

  static ExerciseSearchCubit buildExerciseSearchCubit({MockSearchExercisesUseCase? searchExercisesUseCase}) =>
      ExerciseSearchCubit(searchExercisesUseCase: searchExercisesUseCase ?? MockSearchExercisesUseCase());
}
