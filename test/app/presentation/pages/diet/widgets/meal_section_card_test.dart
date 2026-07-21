import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
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
    void Function(FoodLogEntry entry)? onEditEntry,
    void Function(FoodLogEntry entry)? onDeleteEntry,
  }) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MealSectionCard(
          section: section,
          onAddFood: onAddFood,
          onEditEntry: (entry) => onEditEntry?.call(entry),
          onDeleteEntry: (entry) => onDeleteEntry?.call(entry),
        ),
      ),
    ),
  );

  MealSection buildBreakfast() => MealSection(
    mealType: MealType.breakfast,
    entries: [
      FoodLogEntryFactory.build(
        food: FoodFactory.build(name: 'Oatmeal'),
        log: FoodLogFactory.build(),
      ),
    ],
  );

  testWidgets('starts collapsed and then expands on tap', (tester) async {
    await pumpMealSectionCard(tester, section: buildBreakfast());

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Oatmeal'), findsNothing);

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Oatmeal'), findsOneWidget);
  });

  testWidgets('expanding animates rather than snapping the contents in', (tester) async {
    await pumpMealSectionCard(tester, section: buildBreakfast());

    await tester.tap(find.text('Breakfast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final midFlight = tester.getSize(find.byType(AnimatedSize)).height;

    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AnimatedSize)).height, greaterThan(midFlight));
  });

  testWidgets('shows the add-to-meal cta and reports taps when onAddFood is provided', (tester) async {
    var added = false;
    await pumpMealSectionCard(tester, section: buildBreakfast(), onAddFood: () => added = true);

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

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

  testWidgets('tapping a logged food reports it for editing', (tester) async {
    FoodLogEntry? editedEntry;
    final section = buildBreakfast();
    await pumpMealSectionCard(tester, section: section, onEditEntry: (entry) => editedEntry = entry);

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oatmeal'));
    await tester.pump();

    expect(editedEntry, section.entries.single);
  });

  testWidgets('the delete button removes rather than edits', (tester) async {
    FoodLogEntry? editedEntry;
    FoodLogEntry? deletedEntry;
    final section = buildBreakfast();
    await pumpMealSectionCard(
      tester,
      section: section,
      onEditEntry: (entry) => editedEntry = entry,
      onDeleteEntry: (entry) => deletedEntry = entry,
    );

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(deletedEntry, section.entries.single);
    expect(editedEntry, isNull);
  });
}
