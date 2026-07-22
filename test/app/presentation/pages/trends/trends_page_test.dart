import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/trends/trends_cubit.dart';
import 'package:vitta/app/presentation/pages/trends/trends_page.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_card.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trends_headline_card.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trends_skeleton.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DailyMacros macrosOf(double calories) => DailyMacros(
  entries: [
    FoodLogEntryFactory.build(food: FoodFactory.build(caloriesPer100g: calories), log: FoodLogFactory.build()),
  ],
);

MockGetAppSettingsUseCase stubbedSettings() {
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
  return getAppSettingsUseCase;
}

MockGetMacroGoalsUseCase stubbedMacroGoals() {
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
  return getMacroGoalsUseCase;
}

MockGetWaterGoalUseCase stubbedWaterGoal() {
  final getWaterGoalUseCase = MockGetWaterGoalUseCase();
  when(getWaterGoalUseCase.call).thenReturn(2000);
  return getWaterGoalUseCase;
}

MockGetSleepGoalUseCase stubbedSleepGoal() {
  final getSleepGoalUseCase = MockGetSleepGoalUseCase();
  when(getSleepGoalUseCase.call).thenReturn(8);
  return getSleepGoalUseCase;
}

MockGetWaterInRangeUseCase emptyWater() {
  final getWaterInRangeUseCase = MockGetWaterInRangeUseCase();
  when(() => getWaterInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => const Success({}));
  return getWaterInRangeUseCase;
}

MockGetSleepInRangeUseCase emptySleep() {
  final getSleepInRangeUseCase = MockGetSleepInRangeUseCase();
  when(() => getSleepInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => const Success({}));
  return getSleepInRangeUseCase;
}

MockGetDailyWorkoutsInRangeUseCase emptyWorkouts() {
  final getDailyWorkoutsInRangeUseCase = MockGetDailyWorkoutsInRangeUseCase();
  when(() => getDailyWorkoutsInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => const Success({}));
  return getDailyWorkoutsInRangeUseCase;
}

MockGetBodyWeightInRangeUseCase emptyBodyWeight() {
  final getBodyWeightInRangeUseCase = MockGetBodyWeightInRangeUseCase();
  when(() => getBodyWeightInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => const Success([]));
  return getBodyWeightInRangeUseCase;
}

Future<void> pumpTrendsPage(WidgetTester tester, {required MockGetMacrosInRangeUseCase getMacrosInRangeUseCase, bool settle = true}) async {
  if (G.isRegistered<TrendsCubit>()) {
    G.unregister<TrendsCubit>();
  }
  G.registerFactory<TrendsCubit>(
    () => CubitsFactories.buildTrendsCubit(
      getMacrosInRangeUseCase: getMacrosInRangeUseCase,
      getMacroGoalsUseCase: stubbedMacroGoals(),
      getWaterInRangeUseCase: emptyWater(),
      getWaterGoalUseCase: stubbedWaterGoal(),
      getSleepInRangeUseCase: emptySleep(),
      getSleepGoalUseCase: stubbedSleepGoal(),
      getDailyWorkoutsInRangeUseCase: emptyWorkouts(),
      getBodyWeightInRangeUseCase: emptyBodyWeight(),
      getAppSettingsUseCase: stubbedSettings(),
    ),
  );
  addTearDown(() => G.unregister<TrendsCubit>());

  await tester.pumpWidget(
    MaterialApp.router(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const TrendsPage()),
          GoRoute(path: '/diet/history', name: 'dietHistory', builder: (context, state) => const Scaffold(body: Text('diet history'))),
        ],
      ),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

MockGetMacrosInRangeUseCase stubbedMacros(Map<DateTime, DailyMacros> macrosByDate) {
  final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
  when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(macrosByDate));
  return getMacrosInRangeUseCase;
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  testWidgets('leads with the headline verdict over one card per area', (tester) async {
    await pumpTrendsPage(tester, getMacrosInRangeUseCase: stubbedMacros({today(): macrosOf(2185)}));

    expect(find.byType(TrendsHeadlineCard), findsOneWidget);
    expect(find.byType(TrendAreaCard), findsWidgets);
    expect(find.text("You're on track"), findsOneWidget);
  });

  testWidgets('an area card deep-links into that feature history', (tester) async {
    await pumpTrendsPage(tester, getMacrosInRangeUseCase: stubbedMacros({today(): macrosOf(2185)}));

    await tester.tap(find.byType(TrendAreaCard).first);
    await tester.pumpAndSettle();

    expect(find.text('diet history'), findsOneWidget);
  });

  testWidgets('a user with nothing tracked gets the empty state, not blank cards', (tester) async {
    await pumpTrendsPage(tester, getMacrosInRangeUseCase: stubbedMacros(const {}));

    expect(find.byType(VTEmptyState), findsOneWidget);
    expect(find.byType(TrendAreaCard), findsNothing);
  });

  testWidgets('the first read shows the skeleton rather than the empty state', (tester) async {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return const Success({});
    });

    await pumpTrendsPage(tester, getMacrosInRangeUseCase: getMacrosInRangeUseCase, settle: false);
    await tester.pump();

    expect(find.byType(TrendsSkeleton), findsOneWidget);
    expect(find.byType(VTEmptyState), findsNothing);

    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
