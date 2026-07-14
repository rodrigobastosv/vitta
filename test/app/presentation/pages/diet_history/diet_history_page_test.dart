import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/diet_day/diet_day_extra.dart';
import 'package:vitta/app/presentation/pages/diet_day/diet_day_page.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

DailyMacros buildDayOf(double calories, {MealType mealType = MealType.breakfast}) => DailyMacros(
  entries: [
    FoodLogEntryFactory.build(
      food: FoodFactory.build(name: 'Oatmeal', caloriesPer100g: calories),
      log: FoodLogFactory.build(mealType: mealType),
    ),
  ],
);

Future<void> pumpHistoryPage(WidgetTester tester, {Map<DateTime, DailyMacros> macrosByDate = const {}}) async {
  final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(macrosByDate));
  when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
  if (G.isRegistered<DietHistoryCubit>()) {
    G.unregister<DietHistoryCubit>();
  }
  G.registerFactory<DietHistoryCubit>(
    () => CubitsFactories.buildDietHistoryCubit(
      getMacrosInRangeUseCase: getMacrosInRangeUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    ),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DietHistoryPage()),
          GoRoute(
            path: '/day',
            name: 'dietDay',
            builder: (context, state) {
              final extra = state.extra! as DietDayExtra;
              return DietDayPage(date: extra.date, dailyMacros: extra.dailyMacros, macroGoals: extra.macroGoals);
            },
          ),
        ],
      ),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  testWidgets('shows the calendar and the trends section on one page', (tester) async {
    await pumpHistoryPage(tester);

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Avg'), findsOneWidget);
    expect(find.text('Trends'), findsOneWidget);
    expect(find.text('30d'), findsOneWidget);
  });

  testWidgets('a week with logged days shows its rounded calorie average', (tester) async {
    final today = DateTime.now();
    final firstOfMonth = DateTime(today.year, today.month);
    await pumpHistoryPage(
      tester,
      macrosByDate: {firstOfMonth: buildDayOf(1000), firstOfMonth.add(const Duration(days: 1)): buildDayOf(2000)},
    );

    expect(find.text('1500'), findsOneWidget);
  });

  testWidgets('renders a calories chart and a macros chart once there is data', (tester) async {
    final today = DateTime.now();
    await pumpHistoryPage(tester, macrosByDate: {DateTime(today.year, today.month, today.day): buildDayOf(2000)});

    await tester.scrollUntilVisible(find.byType(VTBarChart).first, 200);
    await tester.pumpAndSettle();

    expect(find.byType(VTBarChart), findsNWidgets(2));
    expect(find.text('Goal'), findsOneWidget);
  });

  testWidgets('the trends section explains itself instead of drawing empty charts', (tester) async {
    await pumpHistoryPage(tester);

    await tester.scrollUntilVisible(find.text('Calories by meal'), 200);
    await tester.pumpAndSettle();

    expect(find.text('Nothing logged in this period yet.'), findsNWidgets(3));
    expect(find.byType(VTBarChart), findsNothing);
    expect(find.byType(VTDistributionBar), findsNothing);
  });

  testWidgets('breaks the range calories down by meal', (tester) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    await pumpHistoryPage(
      tester,
      macrosByDate: {
        todayOnly: buildDayOf(1500, mealType: .dinner),
        todayOnly.subtract(const Duration(days: 1)): buildDayOf(500),
      },
    );

    await tester.scrollUntilVisible(find.text('Calories by meal'), 200);
    await tester.pumpAndSettle();

    expect(find.byType(VTDistributionBar), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('tapping a logged day opens its read-only details page', (tester) async {
    final today = DateTime.now();
    await pumpHistoryPage(tester, macrosByDate: {DateTime(today.year, today.month, today.day): buildDayOf(2000)});

    await tester.tap(find.text('${today.day}'));
    await tester.pumpAndSettle();

    expect(find.byType(DietDayPage), findsOneWidget);
    expect(find.text('Oatmeal'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('a day with nothing logged is not tappable', (tester) async {
    final today = DateTime.now();
    await pumpHistoryPage(tester, macrosByDate: {DateTime(today.year, today.month, today.day): const DailyMacros(entries: [])});

    await tester.tap(find.text('${today.day}'));
    await tester.pumpAndSettle();

    expect(find.byType(DietDayPage), findsNothing);
  });
}
