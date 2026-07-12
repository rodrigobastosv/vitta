import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/delete_sleep_log_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/log_sleep_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';

import '../mocks/repositories_mocks.dart';

abstract class UseCasesFactories {
  static SearchFoodsUseCase buildSearchFoodsUseCase({MockDietRepository? dietRepository}) =>
      SearchFoodsUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static LogFoodUseCase buildLogFoodUseCase({MockDietRepository? dietRepository}) =>
      LogFoodUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static GetDailyMacrosUseCase buildGetDailyMacrosUseCase({MockDietRepository? dietRepository}) =>
      GetDailyMacrosUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static DeleteFoodLogUseCase buildDeleteFoodLogUseCase({MockDietRepository? dietRepository}) =>
      DeleteFoodLogUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static LogWaterUseCase buildLogWaterUseCase({MockWaterRepository? waterRepository}) =>
      LogWaterUseCase(waterRepository: waterRepository ?? MockWaterRepository());

  static GetDailyWaterUseCase buildGetDailyWaterUseCase({MockWaterRepository? waterRepository}) =>
      GetDailyWaterUseCase(waterRepository: waterRepository ?? MockWaterRepository());

  static DeleteWaterLogUseCase buildDeleteWaterLogUseCase({MockWaterRepository? waterRepository}) =>
      DeleteWaterLogUseCase(waterRepository: waterRepository ?? MockWaterRepository());

  static LogSleepUseCase buildLogSleepUseCase({MockSleepRepository? sleepRepository}) =>
      LogSleepUseCase(sleepRepository: sleepRepository ?? MockSleepRepository());

  static GetRecentSleepLogsUseCase buildGetRecentSleepLogsUseCase({MockSleepRepository? sleepRepository}) =>
      GetRecentSleepLogsUseCase(sleepRepository: sleepRepository ?? MockSleepRepository());

  static DeleteSleepLogUseCase buildDeleteSleepLogUseCase({MockSleepRepository? sleepRepository}) =>
      DeleteSleepLogUseCase(sleepRepository: sleepRepository ?? MockSleepRepository());

  static CompleteOnboardingUseCase buildCompleteOnboardingUseCase({MockOnboardingRepository? onboardingRepository}) =>
      CompleteOnboardingUseCase(onboardingRepository: onboardingRepository ?? MockOnboardingRepository());
}
