import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';

import '../mocks/datasources_mocks.dart';
import '../mocks/use_cases_mocks.dart';

abstract class CubitsFactories {
  static AppCubit buildAppCubit({MockSettingsLocalDataSource? settingsLocalDataSource}) =>
      AppCubit(settingsLocalDataSource: settingsLocalDataSource ?? MockSettingsLocalDataSource());

  static AuthCubit buildAuthCubit({
    MockGetAuthStatusUseCase? getAuthStatusUseCase,
    MockSignUpUseCase? signUpUseCase,
    MockSignInUseCase? signInUseCase,
    MockSignOutUseCase? signOutUseCase,
  }) => AuthCubit(
    getAuthStatusUseCase: getAuthStatusUseCase ?? MockGetAuthStatusUseCase(),
    signUpUseCase: signUpUseCase ?? MockSignUpUseCase(),
    signInUseCase: signInUseCase ?? MockSignInUseCase(),
    signOutUseCase: signOutUseCase ?? MockSignOutUseCase(),
  );

  static DietCubit buildDietCubit({MockGetDailyMacrosUseCase? getDailyMacrosUseCase, MockDeleteFoodLogUseCase? deleteFoodLogUseCase}) =>
      DietCubit(
        getDailyMacrosUseCase: getDailyMacrosUseCase ?? MockGetDailyMacrosUseCase(),
        deleteFoodLogUseCase: deleteFoodLogUseCase ?? MockDeleteFoodLogUseCase(),
      );

  static FoodSearchCubit buildFoodSearchCubit({MockSearchFoodsUseCase? searchFoodsUseCase, MockLogFoodUseCase? logFoodUseCase}) =>
      FoodSearchCubit(
        searchFoodsUseCase: searchFoodsUseCase ?? MockSearchFoodsUseCase(),
        logFoodUseCase: logFoodUseCase ?? MockLogFoodUseCase(),
      );

  static OnboardingCubit buildOnboardingCubit({MockCompleteOnboardingUseCase? completeOnboardingUseCase}) =>
      OnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase ?? MockCompleteOnboardingUseCase());

  static WaterCubit buildWaterCubit({
    MockGetDailyWaterUseCase? getDailyWaterUseCase,
    MockLogWaterUseCase? logWaterUseCase,
    MockDeleteWaterLogUseCase? deleteWaterLogUseCase,
    MockWaterLocalDataSource? waterLocalDataSource,
  }) => WaterCubit(
    getDailyWaterUseCase: getDailyWaterUseCase ?? MockGetDailyWaterUseCase(),
    logWaterUseCase: logWaterUseCase ?? MockLogWaterUseCase(),
    deleteWaterLogUseCase: deleteWaterLogUseCase ?? MockDeleteWaterLogUseCase(),
    waterLocalDataSource: waterLocalDataSource ?? MockWaterLocalDataSource(),
  );

  static SleepCubit buildSleepCubit({
    MockGetRecentSleepLogsUseCase? getRecentSleepLogsUseCase,
    MockLogSleepUseCase? logSleepUseCase,
    MockDeleteSleepLogUseCase? deleteSleepLogUseCase,
  }) => SleepCubit(
    getRecentSleepLogsUseCase: getRecentSleepLogsUseCase ?? MockGetRecentSleepLogsUseCase(),
    logSleepUseCase: logSleepUseCase ?? MockLogSleepUseCase(),
    deleteSleepLogUseCase: deleteSleepLogUseCase ?? MockDeleteSleepLogUseCase(),
  );
}
