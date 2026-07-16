import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_summary_card.dart';
import 'package:vitta/app/presentation/pages/diet_day/diet_day_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';

Future<void> pumpDietDayPage(WidgetTester tester, {required DailyMacros dailyMacros}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: DietDayPage(date: DateTime(2026, 7, 11), dailyMacros: dailyMacros, macroGoals: MacroGoalsFactory.build()),
  ),
);

void main() {
  testWidgets('shows the day it is describing and its macro summary', (tester) async {
    await pumpDietDayPage(
      tester,
      dailyMacros: DailyMacros(
        entries: [FoodLogEntryFactory.build(food: FoodFactory.build(name: 'Oatmeal'))],
      ),
    );

    expect(find.text('Saturday, July 11, 2026'), findsOneWidget);
    expect(find.byType(MacroSummaryCard), findsOneWidget);
  });

  testWidgets('opens with the meals already expanded so every food is visible', (tester) async {
    await pumpDietDayPage(
      tester,
      dailyMacros: DailyMacros(
        entries: [
          FoodLogEntryFactory.build(
            food: FoodFactory.build(name: 'Oatmeal'),
            log: FoodLogFactory.build(),
          ),
          FoodLogEntryFactory.build(
            food: FoodFactory.build(name: 'Salad'),
            log: FoodLogFactory.build(mealType: .lunch),
          ),
        ],
      ),
    );

    expect(find.text('Oatmeal'), findsOneWidget);
    expect(find.text('Salad'), findsOneWidget);
  });

  testWidgets('offers no way to change anything', (tester) async {
    await pumpDietDayPage(tester, dailyMacros: DailyMacros(entries: [FoodLogEntryFactory.build()]));

    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.textContaining('Add to'), findsNothing);
  });

  testWidgets('still surfaces micronutrients so the day reads as complete', (tester) async {
    await pumpDietDayPage(
      tester,
      dailyMacros: DailyMacros(
        entries: [
          FoodLogEntryFactory.build(food: FoodFactory.build(micronutrientsPer100g: const {Nutrient.iron: 0.01})),
        ],
      ),
    );

    await tester.tap(find.text('Vitamins & minerals'));
    await tester.pumpAndSettle();

    expect(find.text('Iron'), findsOneWidget);
  });

  testWidgets('says so when the day has nothing logged', (tester) async {
    await pumpDietDayPage(tester, dailyMacros: const DailyMacros(entries: []));

    expect(find.text('Nothing was logged on this day.'), findsOneWidget);
  });
}
