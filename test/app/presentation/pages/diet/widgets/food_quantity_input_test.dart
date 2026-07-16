import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';

Future<void> pumpInput(
  WidgetTester tester, {
  required Food food,
  required TextEditingController controller,
  FoodQuantityMode mode = FoodQuantityMode.weight,
  UnitSystem unitSystem = UnitSystem.metric,
  ValueChanged<FoodQuantityMode>? onModeChanged,
}) {
  addTearDown(controller.dispose);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FoodQuantityInput(
          food: food,
          controller: controller,
          mode: mode,
          onModeChanged: onModeChanged ?? (_) {},
          unitSystem: unitSystem,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('offers no unit mode for a food nobody counts', (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Arroz'),
      controller: TextEditingController(text: '100'),
    );

    expect(find.text('Units'), findsNothing);
    expect(find.text('Weight'), findsNothing);
    expect(find.text('Quantity (g)'), findsOneWidget);
  });

  testWidgets('offers the unit mode once the food has a unit weight', (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      controller: TextEditingController(text: '100'),
    );

    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
  });

  testWidgets('spells out what a count weighs, live as it is typed', (tester) async {
    final controller = TextEditingController(text: '2');
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      controller: controller,
      mode: FoodQuantityMode.units,
    );

    expect(find.text('2 un = 100 g'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();

    expect(find.text('3 un = 150 g'), findsOneWidget);
  });

  testWidgets("states the equivalent weight in the reader's own unit system", (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      controller: TextEditingController(text: '2'),
      mode: FoodQuantityMode.units,
      unitSystem: UnitSystem.imperial,
    );

    expect(find.text('2 un = 3.5 oz'), findsOneWidget);
  });

  testWidgets('says nothing about a count that is not a usable number yet', (tester) async {
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      controller: TextEditingController(),
      mode: FoodQuantityMode.units,
    );

    expect(find.textContaining('un ='), findsNothing);
  });

  testWidgets('reports the mode the user picked', (tester) async {
    final modes = <FoodQuantityMode>[];
    await pumpInput(
      tester,
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
      controller: TextEditingController(text: '100'),
      onModeChanged: modes.add,
    );

    await tester.tap(find.text('Units'));
    await tester.pump();

    expect(modes, [FoodQuantityMode.units]);
  });
}
