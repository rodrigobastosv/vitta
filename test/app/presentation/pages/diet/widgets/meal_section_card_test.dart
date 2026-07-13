import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/meal_section.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/meal_section_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../../factories/entities/food_log_factory.dart';

void main() {
  Future<void> pumpMealSectionCard(
    WidgetTester tester, {
    required MealSection section,
    VoidCallback? onAddFood,
    void Function(dynamic entry)? onDeleteEntry,
  }) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MealSectionCard(
          section: section,
          onAddFood: onAddFood,
          onDeleteEntry: (entry) => onDeleteEntry?.call(entry),
        ),
      ),
    ),
  );

  MealSection buildBreakfast() => MealSection(
    mealType: MealType.breakfast,
    entries: [
      FoodLogEntryFactory.build(food: FoodFactory.build(name: 'Oatmeal'), log: FoodLogFactory.build()),
    ],
  );

  testWidgets('starts expanded showing its entries, then collapses on tap', (tester) async {
    await pumpMealSectionCard(tester, section: buildBreakfast());

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Oatmeal'), findsOneWidget);

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Oatmeal'), findsNothing);
  });

  testWidgets('shows the add-to-meal cta and reports taps when onAddFood is provided', (tester) async {
    var added = false;
    await pumpMealSectionCard(tester, section: buildBreakfast(), onAddFood: () => added = true);

    final addCta = find.text('Add to Breakfast');
    expect(addCta, findsOneWidget);

    await tester.tap(addCta);
    await tester.pump();

    expect(added, isTrue);
  });

  testWidgets('hides the add-to-meal cta when onAddFood is null', (tester) async {
    await pumpMealSectionCard(tester, section: buildBreakfast());

    expect(find.text('Add to Breakfast'), findsNothing);
  });
}
