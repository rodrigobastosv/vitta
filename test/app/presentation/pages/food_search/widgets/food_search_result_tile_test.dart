import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_search_result_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';

void main() {
  Future<void> pumpTile(WidgetTester tester, {VoidCallback? onTap, VoidCallback? onAdd}) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FoodSearchResultTile(
          food: FoodFactory.build(brand: 'Chiquita'),
          heroTag: 'tag',
          onTap: onTap ?? () {},
          onAdd: onAdd ?? () {},
        ),
      ),
    ),
  );

  testWidgets('shows the food summary with a hero image', (tester) async {
    await pumpTile(tester);

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Chiquita'), findsOneWidget);
    expect(tester.widget<Hero>(find.byType(Hero)).tag, 'tag');
    expect(find.descendant(of: find.byType(Hero), matching: find.byType(VTFoodImage)), findsOneWidget);
  });

  testWidgets('calls onTap when the card is tapped', (tester) async {
    var taps = 0;
    await pumpTile(tester, onTap: () => taps++);

    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('calls onAdd when the add button is tapped', (tester) async {
    var added = 0;
    await pumpTile(tester, onAdd: () => added++);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(added, 1);
  });
}
