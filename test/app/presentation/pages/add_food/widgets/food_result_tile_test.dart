import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/food_result_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';

void main() {
  Future<void> pumpTile(WidgetTester tester, {VoidCallback? onTap, VoidCallback? onAdd, Food? food}) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FoodResultTile(
          food: food ?? FoodFactory.build(brand: 'Chiquita'),
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
    expect(find.textContaining('Chiquita'), findsOneWidget);
    expect(tester.widget<Hero>(find.byType(Hero)).tag, 'tag');
    expect(find.descendant(of: find.byType(Hero), matching: find.byType(VTFoodImage)), findsOneWidget);
  });

  testWidgets('a branded and an unbranded row are the same height, so the list is not ragged', (tester) async {
    await pumpTile(tester);
    final branded = tester.getSize(find.byType(FoodResultTile)).height;

    await pumpTile(tester, food: FoodFactory.build());
    final unbranded = tester.getSize(find.byType(FoodResultTile)).height;

    expect(unbranded, branded);
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
