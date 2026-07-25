import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_stepper.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';

final _measureField = find.byWidgetPredicate(
  (widget) => widget is TextField && (widget.decoration?.labelText?.startsWith('Quantity') ?? false),
);
final _unitsField = find.descendant(of: find.byType(VTStepper), matching: find.byType(TextField));

String? _measureLabel(WidgetTester tester) => tester.widget<TextField>(_measureField).decoration?.labelText;

Future<void> pumpInput(
  WidgetTester tester, {
  required Food food,
  required ValueChanged<LoggedQuantity?> onChanged,
  required LoggedQuantity initialQuantity,
  UnitSystem unitSystem = UnitSystem.metric,
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: FoodQuantityInput(food: food, unitSystem: unitSystem, onChanged: onChanged, initialQuantity: initialQuantity),
    ),
  ),
);

void main() {
  testWidgets('a food nobody counts shows only the weight field', (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Arroz'),
      initialQuantity: const LoggedQuantity.weight(100),
      onChanged: (_) {},
    );

    expect(_measureField, findsOneWidget);
    expect(_measureLabel(tester), 'Quantity (g)');
    expect(find.byType(VTStepper), findsNothing);
  });

  testWidgets('a countable food shows both the weight field and the units stepper', (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialQuantity: const LoggedQuantity.weight(100),
      onChanged: (_) {},
    );

    expect(_measureField, findsOneWidget);
    expect(find.byType(VTStepper), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('typing a count fills the weight field and records the count', (tester) async {
    final quantities = <LoggedQuantity?>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialQuantity: const LoggedQuantity.weight(100),
      onChanged: quantities.add,
    );

    await tester.enterText(_unitsField, '3');
    await tester.pump();

    expect(quantities.last?.grams, 150);
    expect(quantities.last?.units, 3);
    expect(tester.widget<TextField>(_measureField).controller?.text, '150');
  });

  testWidgets('typing a weight fills the units and records no count', (tester) async {
    final quantities = <LoggedQuantity?>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialQuantity: const LoggedQuantity.weight(100),
      onChanged: quantities.add,
    );

    await tester.enterText(_measureField, '200');
    await tester.pump();

    expect(quantities.last?.grams, 200);
    expect(quantities.last?.units, isNull);
    expect(tester.widget<TextField>(_unitsField).controller?.text, '4');
  });

  testWidgets('a count fills the weight in the reader own unit system', (tester) async {
    final quantities = <LoggedQuantity?>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      initialQuantity: const LoggedQuantity.weight(50),
      unitSystem: .imperial,
      onChanged: quantities.add,
    );

    await tester.enterText(_unitsField, '2');
    await tester.pump();

    expect(quantities.last?.grams, 100);
    expect(tester.widget<TextField>(_measureField).controller?.text, '3.5');
  });

  group('a liquid', () {
    testWidgets('is measured in millilitres rather than grams', (tester) async {
      final quantities = <LoggedQuantity?>[];
      await pumpInput(
        tester,
        food: FoodFactory.build(name: 'Leite', densityGPerMl: 1.03),
        initialQuantity: const LoggedQuantity.volume(milliliters: 200, grams: 206),
        onChanged: quantities.add,
      );

      expect(_measureLabel(tester), 'Quantity (mL)');
      expect(tester.widget<TextField>(_measureField).controller?.text, '200');
      expect(find.byType(VTStepper), findsNothing);

      await tester.enterText(_measureField, '300');
      await tester.pump();

      expect(quantities.last?.milliliters, 300);
      expect(quantities.last?.grams, closeTo(309, 0.01));
    });

    testWidgets('reads in fluid ounces for an imperial reader but still records millilitres', (tester) async {
      final quantities = <LoggedQuantity?>[];
      await pumpInput(
        tester,
        food: FoodFactory.build(name: 'Leite', densityGPerMl: 1),
        initialQuantity: const LoggedQuantity.volume(milliliters: 200, grams: 200),
        unitSystem: .imperial,
        onChanged: quantities.add,
      );

      expect(_measureLabel(tester), 'Quantity (fl oz)');
      expect(tester.widget<TextField>(_measureField).controller?.text, '6.8');

      await tester.enterText(_measureField, '8');
      await tester.pump();

      expect(quantities.last?.milliliters, closeTo(236.59, 0.01));
    });

    testWidgets('that is also countable keeps the stepper and measures the rest in millilitres', (tester) async {
      final quantities = <LoggedQuantity?>[];
      await pumpInput(
        tester,
        food: FoodFactory.build(name: 'Coca-Cola lata', densityGPerMl: 1.04, gramsPerUnit: 364),
        initialQuantity: const LoggedQuantity.units(units: 1, grams: 364),
        onChanged: quantities.add,
      );

      expect(_measureLabel(tester), 'Quantity (mL)');
      expect(find.byType(VTStepper), findsOneWidget);
      expect(tester.widget<TextField>(_measureField).controller?.text, '350');

      await tester.enterText(_unitsField, '2');
      await tester.pump();

      expect(quantities.last?.units, 2);
      expect(quantities.last?.grams, 728);
      expect(tester.widget<TextField>(_measureField).controller?.text, '700');
    });
  });

  testWidgets('an empty field reports no quantity at all', (tester) async {
    final quantities = <LoggedQuantity?>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Arroz'),
      initialQuantity: const LoggedQuantity.weight(100),
      onChanged: quantities.add,
    );

    await tester.enterText(_measureField, '');
    await tester.pump();

    expect(quantities.last, isNull);
  });
}
