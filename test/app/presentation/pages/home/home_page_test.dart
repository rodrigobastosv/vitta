import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_page.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_skeleton.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_today_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
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
    when(() => getRemindersInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer(
      (_) async => Success(reminders.isEmpty ? const {} : {todayOnly: reminders}),
    );
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
      FoodLogEntryFactory.build(food: FoodFactory.build(name: 'Oatmeal', caloriesPer100g: calories), log: FoodLogFactory.build()),
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
}
