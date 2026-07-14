import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_details_dialog.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, {Map<Nutrient, double> micronutrients = const {}}) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FoodDetailsDialog(food: FoodFactory.build(micronutrientsPer100g: micronutrients), heroTag: 'tag'),
      ),
    ),
  );

  testWidgets('shows the full macro and micronutrient breakdown', (tester) async {
    await pumpDialog(tester, micronutrients: const {Nutrient.vitaminC: 0.02});

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Protein 1.1 g'), findsOneWidget);
    expect(find.text('Carbs 22.8 g'), findsOneWidget);
    expect(find.text('Nutrition per 100g'), findsOneWidget);
    expect(find.text('Vitamin C'), findsOneWidget);
  });
}
