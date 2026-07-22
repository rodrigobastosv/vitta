import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_stepper.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_selection.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';

final _weightField = find.byWidgetPredicate((widget) => widget is TextField && (widget.decoration?.labelText?.startsWith('Quantity') ?? false));
final _unitsField = find.descendant(of: find.byType(VTStepper), matching: find.byType(TextField));

Future<void> pumpInput(
  WidgetTester tester, {
  required Food food,
  required ValueChanged<FoodQuantitySelection> onChanged,
  double? initialGrams,
  double? initialUnits,
  UnitSystem unitSystem = UnitSystem.metric,
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: FoodQuantityInput(food: food, unitSystem: unitSystem, onChanged: onChanged, initialGrams: initialGrams, initialUnits: initialUnits),
    ),
  ),
);

void main() {
  testWidgets('a food nobody counts shows only the weight field', (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Arroz'),
      initialGrams: 100,
      onChanged: (_) {},
    );

    expect(_weightField, findsOneWidget);
    expect(find.byType(VTStepper), findsNothing);
  });

  testWidgets('a countable food shows both the weight field and the units stepper', (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialGrams: 100,
      onChanged: (_) {},
    );

    expect(_weightField, findsOneWidget);
    expect(find.byType(VTStepper), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('typing a count fills the weight field and records the count', (tester) async {
    final selections = <FoodQuantitySelection>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialGrams: 100,
      onChanged: selections.add,
    );

    await tester.enterText(_unitsField, '3');
    await tester.pump();

    expect(selections.last.quantityGrams, 150);
    expect(selections.last.quantityUnits, 3);
    expect(tester.widget<TextField>(_weightField).controller?.text, '150');
  });

  testWidgets('typing a weight fills the units and records no count', (tester) async {
    final selections = <FoodQuantitySelection>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialGrams: 100,
      onChanged: selections.add,
    );

    await tester.enterText(_weightField, '200');
    await tester.pump();

    expect(selections.last.quantityGrams, 200);
    expect(selections.last.quantityUnits, isNull);
    expect(tester.widget<TextField>(_unitsField).controller?.text, '4');
  });

  testWidgets('a count fills the weight in the reader own unit system', (tester) async {
    final selections = <FoodQuantitySelection>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialGrams: 50,
      unitSystem: .imperial,
      onChanged: selections.add,
    );

    await tester.enterText(_unitsField, '2');
    await tester.pump();

    expect(selections.last.quantityGrams, 100);
    expect(tester.widget<TextField>(_weightField).controller?.text, '3.5');
  });
}
