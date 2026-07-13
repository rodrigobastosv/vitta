import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_in_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_up_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
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

import '../mocks/repositories_mocks.dart';

abstract class UseCasesFactories {
  static GetAppSettingsUseCase buildGetAppSettingsUseCase({MockSettingsRepository? settingsRepository}) =>
      GetAppSettingsUseCase(settingsRepository: settingsRepository ?? MockSettingsRepository());

  static SaveAppSettingsUseCase buildSaveAppSettingsUseCase({MockSettingsRepository? settingsRepository}) =>
      SaveAppSettingsUseCase(settingsRepository: settingsRepository ?? MockSettingsRepository());

  static SearchFoodsUseCase buildSearchFoodsUseCase({MockDietRepository? dietRepository}) =>
      SearchFoodsUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static LogFoodUseCase buildLogFoodUseCase({MockDietRepository? dietRepository}) =>
      LogFoodUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static GetDailyMacrosUseCase buildGetDailyMacrosUseCase({MockDietRepository? dietRepository}) =>
      GetDailyMacrosUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static DeleteFoodLogUseCase buildDeleteFoodLogUseCase({MockDietRepository? dietRepository}) =>
      DeleteFoodLogUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static GetMacroGoalsUseCase buildGetMacroGoalsUseCase({MockDietRepository? dietRepository}) =>
      GetMacroGoalsUseCase(dietRepository: dietRepository ?? MockDietRepository());

  static SaveMacroGoalsUseCase buildSaveMacroGoalsUseCase({MockDietRepository? dietRepository}) =>
      SaveMacroGoalsUseCase(dietRepository: dietRepository ?? MockDietRepository());

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

  static HasSeenOnboardingUseCase buildHasSeenOnboardingUseCase({MockOnboardingRepository? onboardingRepository}) =>
      HasSeenOnboardingUseCase(onboardingRepository: onboardingRepository ?? MockOnboardingRepository());

  static GetUserUseCase buildGetUserUseCase({MockAuthRepository? authRepository}) =>
      GetUserUseCase(authRepository: authRepository ?? MockAuthRepository());

  static SignUpUseCase buildSignUpUseCase({MockAuthRepository? authRepository}) =>
      SignUpUseCase(authRepository: authRepository ?? MockAuthRepository());

  static SignInUseCase buildSignInUseCase({MockAuthRepository? authRepository}) =>
      SignInUseCase(authRepository: authRepository ?? MockAuthRepository());

  static SignOutUseCase buildSignOutUseCase({MockAuthRepository? authRepository}) =>
      SignOutUseCase(authRepository: authRepository ?? MockAuthRepository());
}
