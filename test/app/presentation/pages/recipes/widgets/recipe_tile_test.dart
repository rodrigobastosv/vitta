import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/recipes/widgets/recipe_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/recipe_factory.dart';

Future<void> pumpTile(WidgetTester tester, {required VoidCallback onLog}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: RecipeTile(recipe: RecipeFactory.build(), onEdit: () {}, onDelete: () {}, onLog: onLog)),
  ),
);

void main() {
  testWidgets('the add-to-meal button fires onLog', (tester) async {
    var logged = false;
    await pumpTile(tester, onLog: () => logged = true);

    await tester.tap(find.byTooltip('Add to meal'));

    expect(logged, isTrue);
  });
}
