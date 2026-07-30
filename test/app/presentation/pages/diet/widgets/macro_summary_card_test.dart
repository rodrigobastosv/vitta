import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_summary_card.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/nutrition_score_row.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../../factories/entities/food_log_factory.dart';

void main() {
  Future<void> pumpMacroSummaryCard(WidgetTester tester, {required DailyMacros dailyMacros, VoidCallback? onOpenScore}) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: MacroSummaryCard(dailyMacros: dailyMacros, macroGoals: MacroGoals.defaultGoals, onOpenScore: onOpenScore),
        ),
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

  testWidgets('colors the calorie ring red when the day is far off its goals', (tester) async {
    final farOffDay = DailyMacros(
      entries: [FoodLogEntryFactory.build(food: FoodFactory.build(caloriesPer100g: 100000), log: FoodLogFactory.build())],
    );
    await pumpMacroSummaryCard(tester, dailyMacros: farOffDay);

    expect(tester.widget<VTMacroRing>(find.byType(VTMacroRing)).color, VTColors.error);
  });

  testWidgets('colors the calorie ring green when the day meets its goals', (tester) async {
    final metDay = DailyMacros(
      entries: [
        FoodLogEntryFactory.build(
          food: FoodFactory.build(caloriesPer100g: 200, proteinPer100g: 15, carbsPer100g: 25, fatPer100g: 6.5, fiberPer100g: 3),
          log: FoodLogFactory.build(quantityGrams: 1000),
        ),
      ],
    );
    await pumpMacroSummaryCard(tester, dailyMacros: metDay);

    expect(tester.widget<VTMacroRing>(find.byType(VTMacroRing)).color, VTColors.green);
  });

  testWidgets('the score opens from the card once the day has something in it', (tester) async {
    var opened = false;
    await pumpMacroSummaryCard(tester, dailyMacros: buildDailyMacros(const {}), onOpenScore: () => opened = true);

    await tester.tap(find.byType(NutritionScoreRow));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
  });

  // A day nobody has logged anything on would score 0 out of 100, which is a
  // verdict on a day that has not happened yet.
  testWidgets('an empty day is not scored at all', (tester) async {
    await pumpMacroSummaryCard(tester, dailyMacros: const DailyMacros(entries: []), onOpenScore: () {});

    expect(find.byType(NutritionScoreRow), findsNothing);
  });

  testWidgets('passing no callback leaves the score off the card', (tester) async {
    await pumpMacroSummaryCard(tester, dailyMacros: buildDailyMacros(const {}));

    expect(find.byType(NutritionScoreRow), findsNothing);
  });
}
