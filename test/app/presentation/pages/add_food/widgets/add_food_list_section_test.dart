import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/add_food_list_section.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpSection(WidgetTester tester, {required int rowCount}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ListView(
        children: [
          AddFoodListSection(
            title: 'Recently entered',
            rows: [for (var index = 0; index < rowCount; index++) Text('Row $index')],
          ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('a section shorter than the cap shows every row and offers no toggle', (tester) async {
    await pumpSection(tester, rowCount: AddFoodListSection.defaultCollapsedCount);
    await tester.pumpAndSettle();

    expect(find.text('Row ${AddFoodListSection.defaultCollapsedCount - 1}'), findsOneWidget);
    expect(find.text('Show more'), findsNothing);
  });

  testWidgets('a longer section is capped until it is expanded, and collapses again', (tester) async {
    await pumpSection(tester, rowCount: AddFoodListSection.defaultCollapsedCount + 3);
    await tester.pumpAndSettle();

    expect(find.text('Row ${AddFoodListSection.defaultCollapsedCount - 1}'), findsOneWidget);
    expect(find.text('Row ${AddFoodListSection.defaultCollapsedCount}'), findsNothing);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(find.text('Row ${AddFoodListSection.defaultCollapsedCount + 2}'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();

    expect(find.text('Row ${AddFoodListSection.defaultCollapsedCount}'), findsNothing);
  });
}
