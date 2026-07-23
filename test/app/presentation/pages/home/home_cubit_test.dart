import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_completion.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_presentation_event.dart';
import 'package:vitta/app/presentation/pages/home/home_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../factories/entities/reminder_factory.dart';
import '../../../../factories/entities/water_log_factory.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

MockNotificationService buildPermissiveNotifications() {
  final notifications = MockNotificationService();
  when(() => notifications.cancel(any())).thenAnswer((_) async {});
  return notifications;
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(ReminderFactory.build());
  });

  ({MockGetUserUseCase user, MockGetMacroGoalsUseCase goals, MockGetHomeLayoutUseCase layout}) buildConstructorReads() {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final getHomeLayoutUseCase = MockGetHomeLayoutUseCase();
    when(getHomeLayoutUseCase.call).thenReturn(HomeLayout.shipped);
    return (user: getUserUseCase, goals: getMacroGoalsUseCase, layout: getHomeLayoutUseCase);
  }

  HomeState buildState({List<Reminder> reminders = const []}) => HomeState(
    user: const AnonymousUser(),
    dailyMacros: const DailyMacros(entries: []),
    macroGoals: MacroGoalsFactory.build(),
    layout: HomeLayout.shipped,
    dailyGoalMl: 2000,
    reminders: reminders,
  );

  blocTest<HomeCubit, HomeState>(
    'quick-adding water counts it before the write lands',
    build: () {
      final reads = buildConstructorReads();
      final logWaterUseCase = MockLogWaterUseCase();
      when(
        () => logWaterUseCase(
          loggedDate: any(named: 'loggedDate'),
          amountMl: any(named: 'amountMl'),
        ),
      ).thenAnswer((_) async => Success(WaterLogFactory.build(amountMl: 300)));
      return CubitsFactories.buildHomeCubit(
        getUserUseCase: reads.user,
        getMacroGoalsUseCase: reads.goals,
        getHomeLayoutUseCase: reads.layout,
        logWaterUseCase: logWaterUseCase,
      );
    },
    seed: buildState,
    act: (cubit) => cubit.addWater(amountMl: 300),
    expect: () => [isA<HomeState>().having((state) => state.consumedMl, 'consumedMl', 300)],
  );

  blocTest<HomeCubit, HomeState>(
    'a failed water write puts the total back where it was',
    build: () {
      final reads = buildConstructorReads();
      final logWaterUseCase = MockLogWaterUseCase();
      when(
        () => logWaterUseCase(
          loggedDate: any(named: 'loggedDate'),
          amountMl: any(named: 'amountMl'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildHomeCubit(
        getUserUseCase: reads.user,
        getMacroGoalsUseCase: reads.goals,
        getHomeLayoutUseCase: reads.layout,
        logWaterUseCase: logWaterUseCase,
      );
    },
    seed: buildState,
    act: (cubit) => cubit.addWater(amountMl: 300),
    expect: () => [
      isA<HomeState>().having((state) => state.consumedMl, 'consumedMl', 300),
      isA<HomeState>().having((state) => state.consumedMl, 'consumedMl', 0),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'ticking a reminder from the headline takes it out of the open list',
    build: () {
      final reads = buildConstructorReads();
      final completeReminderUseCase = MockCompleteReminderUseCase();
      final completed = ReminderFactory.build(completedAt: DateTime(2026, 7, 18, 9));
      when(
        () => completeReminderUseCase(
          reminder: any(named: 'reminder'),
          completed: any(named: 'completed'),
        ),
      ).thenAnswer((_) async => Success(ReminderCompletion(reminder: completed)));
      return CubitsFactories.buildHomeCubit(
        getUserUseCase: reads.user,
        getMacroGoalsUseCase: reads.goals,
        getHomeLayoutUseCase: reads.layout,
        completeReminderUseCase: completeReminderUseCase,
        notificationService: buildPermissiveNotifications(),
      );
    },
    seed: () => buildState(reminders: [ReminderFactory.build()]),
    act: (cubit) => cubit.completeReminder(reminder: ReminderFactory.build()),
    verify: (cubit) => expect(cubit.state.openReminders, isEmpty),
  );

  blocPresentationTest<HomeCubit, HomeState, HomePresentationEvent>(
    'a failed completion reports it and leaves the reminder open',
    build: () {
      final reads = buildConstructorReads();
      final completeReminderUseCase = MockCompleteReminderUseCase();
      when(
        () => completeReminderUseCase(
          reminder: any(named: 'reminder'),
          completed: any(named: 'completed'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildHomeCubit(
        getUserUseCase: reads.user,
        getMacroGoalsUseCase: reads.goals,
        getHomeLayoutUseCase: reads.layout,
        completeReminderUseCase: completeReminderUseCase,
      );
    },
    seed: () => buildState(reminders: [ReminderFactory.build()]),
    act: (cubit) => cubit.completeReminder(reminder: ReminderFactory.build()),
    expectPresentation: () => [isA<HomeError>()],
    verify: (cubit) => expect(cubit.state.openReminders, hasLength(1)),
  );

  blocTest<HomeCubit, HomeState>(
    'logging a weight from the headline reads the new latest back',
    build: () {
      final reads = buildConstructorReads();
      final logBodyWeightUseCase = MockLogBodyWeightUseCase();
      when(
        () => logBodyWeightUseCase(
          loggedDate: any(named: 'loggedDate'),
          weightKg: any(named: 'weightKg'),
        ),
      ).thenAnswer((_) async => Success(BodyWeightLogFactory.build(weightKg: 72.5)));
      final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
      when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => Success(BodyWeightLogFactory.build(weightKg: 72.5)));
      return CubitsFactories.buildHomeCubit(
        getUserUseCase: reads.user,
        getMacroGoalsUseCase: reads.goals,
        getHomeLayoutUseCase: reads.layout,
        logBodyWeightUseCase: logBodyWeightUseCase,
        getLatestBodyWeightUseCase: getLatestBodyWeightUseCase,
      );
    },
    seed: buildState,
    act: (cubit) => cubit.logBodyWeight(loggedDate: DateTime(2026, 7, 23), weightKg: 72.5),
    expect: () => [isA<HomeState>().having((state) => state.latestWeightKg, 'latestWeightKg', 72.5)],
  );
}
