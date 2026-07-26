import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/suggested_meal_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/meal_suggestions_factory.dart';

Future<void> pumpCard(
  WidgetTester tester, {
  required SuggestedMeal meal,
  bool isSelected = false,
  Locale locale = const Locale('en'),
  double width = 400,
}) async {
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
        body: Center(child: SuggestedMealCard(meal: meal, isSelected: isSelected, onTap: () {})),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the card states the option and what it adds up to', (tester) async {
    await pumpCard(
      tester,
      meal: MealSuggestionsFactory.buildMeal(
        items: [MealSuggestionsFactory.buildItem(quantityGrams: 200)],
      ),
    );

    expect(find.text('Chicken and rice'), findsOneWidget);
    expect(find.text('High protein'), findsOneWidget);
    expect(find.text('330 kcal'), findsOneWidget);
  });

  // Selection reads from the primary border and tint alone, the diet-modality
  // call - a check glyph on top of a filled card says the same thing twice.
  testWidgets('selection shows as a border rather than a check glyph', (tester) async {
    await pumpCard(tester, meal: MealSuggestionsFactory.buildMeal(), isSelected: true);

    final decoration = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration as BoxDecoration;

    expect((decoration.border! as Border).top.color, VTTheme.light.colorScheme.primary);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  for (final locale in const [Locale('en'), Locale('pt')]) {
    testWidgets('a long name and summary do not overflow at 320px (${locale.languageCode})', (tester) async {
      await pumpCard(
        tester,
        meal: MealSuggestionsFactory.buildMeal(
          name: 'Frango grelhado com arroz integral e brócolis',
          summary: 'Rica em proteína e rápida de preparar em casa',
        ),
        locale: locale,
        width: 320,
      );

      expect(tester.takeException(), isNull);
    });
  }
}
