import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';

import '../factories/cubits_factories.dart';
import '../factories/entities/macro_goals_factory.dart';
import '../mocks/use_cases_mocks.dart';

/// Home loads six trackers on mount, which a test about some *other* screen has
/// no reason to stand up. This swaps in a cubit whose every read resolves empty.
void registerTestHomeCubit() {
  registerFallbackValue(DateTime(2000));

  final getUserUseCase = MockGetUserUseCase();
  when(getUserUseCase.call).thenReturn(const AnonymousUser());
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
  final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
  when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
  final getDailyWaterUseCase = MockGetDailyWaterUseCase();
  when(() => getDailyWaterUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyWater(entries: [])));
  final getWaterGoalUseCase = MockGetWaterGoalUseCase();
  when(getWaterGoalUseCase.call).thenReturn(2500);
  final getRemindersInRangeUseCase = MockGetRemindersInRangeUseCase();
  when(
    () => getRemindersInRangeUseCase(
      from: any(named: 'from'),
      to: any(named: 'to'),
    ),
  ).thenAnswer((_) async => const Success({}));
  final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
  when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
  final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
  when(() => getRecentSleepLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => const Success([]));
  final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
  when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => const Success(null));
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());

  if (G.isRegistered<HomeCubit>()) {
    G.unregister<HomeCubit>();
  }
  G.registerFactory<HomeCubit>(
    () => CubitsFactories.buildHomeCubit(
      getUserUseCase: getUserUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getDailyWaterUseCase: getDailyWaterUseCase,
      getWaterGoalUseCase: getWaterGoalUseCase,
      getRemindersInRangeUseCase: getRemindersInRangeUseCase,
      getWorkoutsForDateUseCase: getWorkoutsForDateUseCase,
      getRecentSleepLogsUseCase: getRecentSleepLogsUseCase,
      getLatestBodyWeightUseCase: getLatestBodyWeightUseCase,
      getAppSettingsUseCase: getAppSettingsUseCase,
    ),
  );
}
