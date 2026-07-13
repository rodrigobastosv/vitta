import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_summary_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../../factories/entities/food_log_factory.dart';

void main() {
  Future<void> pumpMacroSummaryCard(WidgetTester tester, {required DailyMacros dailyMacros}) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MacroSummaryCard(dailyMacros: dailyMacros, macroGoals: MacroGoals.defaultGoals),
      ),
    ),
  );

  DailyMacros buildDailyMacros(Map<Nutrient, double> micronutrientsPer100g) => DailyMacros(
    entries: [
      FoodLogEntryFactory.build(
        food: FoodFactory.build(micronutrientsPer100g: micronutrientsPer100g),
        log: FoodLogFactory.build(),
      ),
    ],
  );

  testWidgets('is compact by default and the header icon expands to reveal micronutrients', (tester) async {
    await pumpMacroSummaryCard(tester, dailyMacros: buildDailyMacros(const {Nutrient.vitaminC: 0.02}));

    expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    expect(find.text('Vitamin C'), findsNothing);

    await tester.tap(find.byIcon(Icons.unfold_more));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.unfold_less), findsOneWidget);
    expect(find.text('Vitamin C'), findsOneWidget);
    expect(find.text('20 mg'), findsOneWidget);
  });

  testWidgets('shows no version toggle when no micronutrients are present', (tester) async {
    await pumpMacroSummaryCard(tester, dailyMacros: buildDailyMacros(const {}));

    expect(find.byIcon(Icons.unfold_more), findsNothing);
    expect(find.text('Vitamins & minerals'), findsNothing);
  });
}
