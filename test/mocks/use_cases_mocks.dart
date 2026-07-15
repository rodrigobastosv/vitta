import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_in_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_up_use_case.dart';
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
import 'package:vitta/app/domain/diet/use_cases/get_recipes_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/remove_recent_search_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/scan_nutrition_label_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/unfavorite_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/update_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/upload_food_image_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/save_app_settings_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/delete_sleep_log_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_in_range_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/log_sleep_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/save_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_goal_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_water_in_range_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';

class MockSearchFoodsUseCase extends Mock implements SearchFoodsUseCase {}

class MockUploadFoodImageUseCase extends Mock implements UploadFoodImageUseCase {}

class MockScanNutritionLabelUseCase extends Mock implements ScanNutritionLabelUseCase {}

class MockLogFoodUseCase extends Mock implements LogFoodUseCase {}

class MockGetDailyMacrosUseCase extends Mock implements GetDailyMacrosUseCase {}

class MockDeleteFoodLogUseCase extends Mock implements DeleteFoodLogUseCase {}

class MockUpdateFoodLogUseCase extends Mock implements UpdateFoodLogUseCase {}

class MockGetRecipesUseCase extends Mock implements GetRecipesUseCase {}

class MockSaveRecipeUseCase extends Mock implements SaveRecipeUseCase {}

class MockDeleteRecipeUseCase extends Mock implements DeleteRecipeUseCase {}

class MockGetMacroGoalsUseCase extends Mock implements GetMacroGoalsUseCase {}

class MockGetMacrosInRangeUseCase extends Mock implements GetMacrosInRangeUseCase {}

class MockCopyFoodLogsUseCase extends Mock implements CopyFoodLogsUseCase {}

class MockSaveMacroGoalsUseCase extends Mock implements SaveMacroGoalsUseCase {}

class MockLogWaterUseCase extends Mock implements LogWaterUseCase {}

class MockGetDailyWaterUseCase extends Mock implements GetDailyWaterUseCase {}

class MockDeleteWaterLogUseCase extends Mock implements DeleteWaterLogUseCase {}

class MockLogSleepUseCase extends Mock implements LogSleepUseCase {}

class MockGetRecentSleepLogsUseCase extends Mock implements GetRecentSleepLogsUseCase {}

class MockDeleteSleepLogUseCase extends Mock implements DeleteSleepLogUseCase {}

class MockCompleteOnboardingUseCase extends Mock implements CompleteOnboardingUseCase {}

class MockGetUserUseCase extends Mock implements GetUserUseCase {}

class MockGetAppSettingsUseCase extends Mock implements GetAppSettingsUseCase {}

class MockSaveAppSettingsUseCase extends Mock implements SaveAppSettingsUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetFavoriteFoodsUseCase extends Mock implements GetFavoriteFoodsUseCase {}

class MockFavoriteFoodUseCase extends Mock implements FavoriteFoodUseCase {}

class MockUnfavoriteFoodUseCase extends Mock implements UnfavoriteFoodUseCase {}

class MockGetRecentSearchesUseCase extends Mock implements GetRecentSearchesUseCase {}

class MockAddRecentSearchUseCase extends Mock implements AddRecentSearchUseCase {}

class MockRemoveRecentSearchUseCase extends Mock implements RemoveRecentSearchUseCase {}

class MockClearRecentSearchesUseCase extends Mock implements ClearRecentSearchesUseCase {}

class MockGetSleepGoalUseCase extends Mock implements GetSleepGoalUseCase {}

class MockSaveSleepGoalUseCase extends Mock implements SaveSleepGoalUseCase {}

class MockGetSleepInRangeUseCase extends Mock implements GetSleepInRangeUseCase {}

class MockGetWaterInRangeUseCase extends Mock implements GetWaterInRangeUseCase {}

class MockGetWaterGoalUseCase extends Mock implements GetWaterGoalUseCase {}
