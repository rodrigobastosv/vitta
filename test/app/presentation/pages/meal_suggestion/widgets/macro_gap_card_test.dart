import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_gap.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/macro_gap_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../../factories/entities/food_log_factory.dart';

const _goals = MacroGoals.defaultGoals;

Future<void> pumpCard(WidgetTester tester, {required MacroGap gap, Locale locale = const Locale('en'), double width = 400}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(child: MacroGapCard(gap: gap)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

MacroGap _gapAfter({required double grams, double caloriesPer100g = 100}) => MacroGap.between(
  consumed: DailyMacros(
    entries: [
      FoodLogEntryFactory.build(log: FoodLogFactory.build(quantityGrams: grams), food: FoodFactory.build(caloriesPer100g: caloriesPer100g)),
    ],
  ),
  goals: _goals,
);

void main() {
  testWidgets('an untouched day states the whole goal as still to eat', (tester) async {
    await pumpCard(tester, gap: MacroGap.between(consumed: const DailyMacros(entries: []), goals: _goals));

    expect(find.text('${_goals.calorieGoal.round()} kcal'), findsOneWidget);
    expect(find.text('Left today'), findsOneWidget);
  });

  // The signed gap is what the model is told; a user reading "-30 g" as an
  // amount left to eat is the reason the card floors it at zero and says the
  // goal is met in words instead.
  testWidgets('a day past its goal reads as met rather than as a negative amount', (tester) async {
    await pumpCard(tester, gap: _gapAfter(grams: 10000));

    expect(find.text('0 kcal'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing);
    expect(find.text('You have already hit your calorie goal for this day.'), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('pt')]) {
    // A title, a calorie badge and four macro figures on one narrow card, and pt
    // is longer than en - the class of break that never shows on a wide surface.
    testWidgets('nothing overflows at 320px (${locale.languageCode})', (tester) async {
      await pumpCard(tester, gap: _gapAfter(grams: 250), locale: locale, width: 320);

      expect(tester.takeException(), isNull);
    });
  }
}
