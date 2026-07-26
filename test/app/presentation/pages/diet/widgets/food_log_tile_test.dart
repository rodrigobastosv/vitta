import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_log_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../../factories/entities/food_log_factory.dart';

Future<void> pumpTile(WidgetTester tester, {required FoodLogEntry entry}) => tester.pumpWidget(
  MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: FoodLogTile(entry: entry)),
  ),
);

void main() {
  // A day view that answers "100 g" to someone who typed "2 eggs" is the whole
  // reason quantity_units and quantity_ml are recorded at all, so each mode has to
  // read back in the number that was actually typed.
  testWidgets('a weighed log reads back in grams', (tester) async {
    await pumpTile(tester, entry: FoodLogEntryFactory.build(log: FoodLogFactory.build(quantityGrams: 150)));

    expect(find.textContaining('150 g'), findsOneWidget);
  });

  testWidgets('a counted log reads back in units', (tester) async {
    await pumpTile(
      tester,
      entry: FoodLogEntryFactory.build(
        food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
        log: FoodLogFactory.build(quantityUnits: 2),
      ),
    );

    expect(find.textContaining('2 un'), findsOneWidget);
    expect(find.textContaining('100 g'), findsNothing);
  });

  testWidgets('a poured log reads back in millilitres', (tester) async {
    await pumpTile(
      tester,
      entry: FoodLogEntryFactory.build(
        food: FoodFactory.build(name: 'Leite', densityGPerMl: 1.03),
        log: FoodLogFactory.build(quantityGrams: 206, quantityMl: 200),
      ),
    );

    expect(find.textContaining('200 mL'), findsOneWidget);
    expect(find.textContaining('206 g'), findsNothing);
  });
}
