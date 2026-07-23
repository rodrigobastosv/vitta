import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_page.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_body_weight_hero.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_skeleton.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_today_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  Future<void> pumpHome(
    WidgetTester tester, {
    required User user,
    Size size = const Size(390, 844),
    DailyMacros dailyMacros = const DailyMacros(entries: []),
    List<Reminder> reminders = const [],
    List<BodyWeightLog> weightLogs = const [],
    HomeLayout layout = HomeLayout.shipped,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(user);
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async {
      if (!settle) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
      return Success(dailyMacros);
    });
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
    ).thenAnswer((_) async => Success(reminders.isEmpty ? const {} : {todayOnly: reminders}));
    final getWorkoutsForDateUseCase = MockGetWorkoutsForDateUseCase();
    when(() => getWorkoutsForDateUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
    final getRoutineCycleUseCase = MockGetRoutineCycleUseCase();
    when(getRoutineCycleUseCase.call).thenAnswer((_) async => const Success(RoutineCycle(routines: [])));
    final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
    when(() => getRecentSleepLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => const Success([]));
    final getSleepGoalUseCase = MockGetSleepGoalUseCase();
    when(getSleepGoalUseCase.call).thenReturn(8);
    final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
    when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => Success(weightLogs.firstOrNull));
    final getRecentBodyWeightLogsUseCase = MockGetRecentBodyWeightLogsUseCase();
    when(() => getRecentBodyWeightLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => Success(weightLogs));
    final getHomeLayoutUseCase = MockGetHomeLayoutUseCase();
    when(getHomeLayoutUseCase.call).thenReturn(layout);
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
    final syncLogRemindersUseCase = MockSyncLogRemindersUseCase();
    when(() => syncLogRemindersUseCase(loggedByTracker: any(named: 'loggedByTracker'))).thenAnswer((_) async {});

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
        getRoutineCycleUseCase: getRoutineCycleUseCase,
        getRecentSleepLogsUseCase: getRecentSleepLogsUseCase,
        getSleepGoalUseCase: getSleepGoalUseCase,
        getLatestBodyWeightUseCase: getLatestBodyWeightUseCase,
        getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase,
        getHomeLayoutUseCase: getHomeLayoutUseCase,
        getAppSettingsUseCase: getAppSettingsUseCase,
        syncLogRemindersUseCase: syncLogRemindersUseCase,
      ),
    );
    addTearDown(() => G.unregister<HomeCubit>());

    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
        builder: (context, child) => LoaderOverlay(child: child!),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    }
  }

  DailyMacros buildDayWithMeals(double calories) => DailyMacros(
    entries: [
      FoodLogEntryFactory.build(
        food: FoodFactory.build(name: 'Oatmeal', caloriesPer100g: calories),
        log: FoodLogFactory.build(),
      ),
    ],
  );

  testWidgets('the skeleton stands in for the real layout, not a generic list', (tester) async {
    await pumpHome(tester, user: const AnonymousUser(), settle: false);

    await tester.pump();

    expect(find.byType(HomeSkeleton), findsOneWidget);
    expect(find.byType(HomeTodayCard), findsNothing);

    final skeletonBlocks = tester.widgetList<VTSkeleton>(find.byType(VTSkeleton)).toList();
    expect(skeletonBlocks.length, 6, reason: 'hero, two section labels, the supporting card and two track tiles');

    await tester.pumpAndSettle();

    expect(find.byType(HomeSkeleton), findsNothing);
    expect(find.byType(HomeTodayCard), findsOneWidget);
  });

  testWidgets('greets by name and says what has actually been logged', (tester) async {
    await pumpHome(
      tester,
      user: const AuthenticatedUser(id: 'user-1', email: 'rodrigo@example.com', displayName: 'Rodrigo'),
      dailyMacros: buildDayWithMeals(400),
    );

    expect(find.text('Rodrigo'), findsOneWidget);
    expect(find.text('1 meal logged'), findsOneWidget);
  });

  testWidgets('keeps the app title for an anonymous user with no name', (tester) async {
    await pumpHome(tester, user: const AnonymousUser());

    expect(find.text('Vitta'), findsOneWidget);
    expect(find.text('Nothing logged yet'), findsOneWidget);
  });

  testWidgets('leads with the calorie hero and supports it with today rows', (tester) async {
    await pumpHome(tester, user: const AnonymousUser(), dailyMacros: buildDayWithMeals(400));

    expect(find.text('Also today'), findsOneWidget);
    expect(find.text('Track'), findsOneWidget);
    expect(find.text('Nothing due today'), findsOneWidget);
    expect(find.text('Not tracked yet'), findsNWidgets(2));
  });

  for (final size in const [Size(320, 568), Size(360, 640), Size(390, 844)]) {
    testWidgets('does not overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await pumpHome(
        tester,
        user: const AuthenticatedUser(id: 'user-1', email: 'rodrigo@example.com', displayName: 'Rodrigo'),
        size: size,
        dailyMacros: buildDayWithMeals(400),
      );

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the default layout is the shipped hierarchy: a diet hero over the supporting rows', (tester) async {
    await pumpHome(tester, user: const AnonymousUser(), dailyMacros: buildDayWithMeals(400));

    expect(find.byType(HomeTodayCard), findsOneWidget);
    expect(find.byType(HomeBodyWeightHero), findsNothing);
    expect(find.text('Water'), findsOneWidget);
  });

  testWidgets('a body weight hero is a trend, not the diet ring', (tester) async {
    await pumpHome(
      tester,
      user: const AnonymousUser(),
      weightLogs: [
        BodyWeightLogFactory.build(id: 'log-2', weightKg: 73, loggedDate: DateTime(2026, 7, 20)),
        BodyWeightLogFactory.build(id: 'log-1', weightKg: 76, loggedDate: DateTime(2026, 7)),
      ],
      layout: HomeLayout.shipped.withSlot(feature: .diet, slot: .supporting).withSlot(feature: .bodyWeight, slot: .hero),
    );

    expect(find.byType(HomeBodyWeightHero), findsOneWidget);
    expect(find.byType(HomeTodayCard), findsNothing);
  });

  testWidgets('a second headline joins the first instead of replacing it', (tester) async {
    await pumpHome(
      tester,
      user: const AnonymousUser(),
      dailyMacros: buildDayWithMeals(400),
      weightLogs: [
        BodyWeightLogFactory.build(id: 'log-2', weightKg: 73, loggedDate: DateTime(2026, 7, 20)),
        BodyWeightLogFactory.build(id: 'log-1', weightKg: 76, loggedDate: DateTime(2026, 7)),
      ],
      layout: HomeLayout.shipped.withSlot(feature: .bodyWeight, slot: .hero),
    );

    expect(find.byType(HomeTodayCard), findsOneWidget);
    expect(find.byType(HomeBodyWeightHero), findsOneWidget);
  });

  // The water hero's fill ripples forever, so a page carrying one never settles.
  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump();
    }
  }

  testWidgets('a water headline can be topped up without leaving home', (tester) async {
    await pumpHome(
      tester,
      user: const AnonymousUser(),
      layout: HomeLayout.shipped.withSlot(feature: .diet, slot: .supporting).withSlot(feature: .water, slot: .hero),
      settle: false,
    );
    await pumpUntilLoaded(tester);

    expect(find.text('Quick add'), findsOneWidget);
    expect(find.text('200 mL'), findsOneWidget);
  });

  testWidgets('every feature as a headline still fits the narrowest phone', (tester) async {
    var layout = HomeLayout.shipped;
    for (final feature in HomeFeature.values) {
      layout = layout.withSlot(feature: feature, slot: .hero);
    }

    await pumpHome(tester, user: const AnonymousUser(), size: const Size(320, 568), layout: layout, settle: false);
    await pumpUntilLoaded(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('a hidden feature stops taking space on home', (tester) async {
    await pumpHome(tester, user: const AnonymousUser(), layout: HomeLayout.shipped.withSlot(feature: .water, slot: .hidden));

    expect(find.text('Water'), findsNothing);
    expect(find.text('Reminders'), findsOneWidget);
  });
}
