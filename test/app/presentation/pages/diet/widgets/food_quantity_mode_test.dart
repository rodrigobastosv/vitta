import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';

import '../../../../../factories/entities/food_factory.dart';

void main() {
  test("counting units multiplies by the food's unit weight", () {
    final egg = FoodFactory.build(gramsPerUnit: 50);

    final grams = FoodQuantityMode.units.gramsFor(value: 2, food: egg, unitSystem: UnitSystem.metric);

    expect(grams, 100);
  });

  test('counting units ignores the unit system - two eggs are two eggs either way', () {
    final egg = FoodFactory.build(gramsPerUnit: 50);

    final metric = FoodQuantityMode.units.gramsFor(value: 2, food: egg, unitSystem: UnitSystem.metric);
    final imperial = FoodQuantityMode.units.gramsFor(value: 2, food: egg, unitSystem: UnitSystem.imperial);

    expect(imperial, metric);
  });

  test('counting a food with no unit weight resolves to no grams at all', () {
    final rice = FoodFactory.build();

    final grams = FoodQuantityMode.units.gramsFor(value: 2, food: rice, unitSystem: UnitSystem.metric);

    expect(grams, isNull);
  });

  test('weighing converts through the unit system as it always has', () {
    final egg = FoodFactory.build(gramsPerUnit: 50);

    final metric = FoodQuantityMode.weight.gramsFor(value: 100, food: egg, unitSystem: UnitSystem.metric);
    final imperial = FoodQuantityMode.weight.gramsFor(value: 1, food: egg, unitSystem: UnitSystem.imperial);

    expect(metric, 100);
    expect(imperial, closeTo(28.35, 0.01));
  });

  test('only a counted quantity is recorded as units', () {
    expect(FoodQuantityMode.units.unitsFor(2), 2);
    expect(FoodQuantityMode.weight.unitsFor(100), isNull);
  });
}
