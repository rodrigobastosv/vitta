import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';

import '../../../../../factories/entities/food_factory.dart';

void main() {
  group('measureFor', () {
    test('a liquid is measured in millilitres', () {
      expect(FoodQuantityMode.measureFor(FoodFactory.build(densityGPerMl: 1.03)), FoodQuantityMode.volume);
    });

    test('everything else is measured by weight', () {
      expect(FoodQuantityMode.measureFor(FoodFactory.build()), FoodQuantityMode.weight);
      expect(FoodQuantityMode.measureFor(FoodFactory.build(gramsPerUnit: 50)), FoodQuantityMode.weight);
    });
  });

  group('units', () {
    test("counting units multiplies by the food's unit weight", () {
      final egg = FoodFactory.build(gramsPerUnit: 50);

      final quantity = FoodQuantityMode.units.quantityFor(value: 2, food: egg, unitSystem: .metric);

      expect(quantity?.grams, 100);
      expect(quantity?.units, 2);
      expect(quantity?.milliliters, isNull);
    });

    test('counting units ignores the unit system - two eggs are two eggs either way', () {
      final egg = FoodFactory.build(gramsPerUnit: 50);

      final metric = FoodQuantityMode.units.quantityFor(value: 2, food: egg, unitSystem: .metric);
      final imperial = FoodQuantityMode.units.quantityFor(value: 2, food: egg, unitSystem: .imperial);

      expect(imperial, metric);
    });

    test('counting a food with no unit weight resolves to no quantity at all', () {
      final rice = FoodFactory.build();

      expect(FoodQuantityMode.units.quantityFor(value: 2, food: rice, unitSystem: .metric), isNull);
    });
  });

  group('weight', () {
    test('weighing converts through the unit system as it always has', () {
      final egg = FoodFactory.build(gramsPerUnit: 50);

      final metric = FoodQuantityMode.weight.quantityFor(value: 100, food: egg, unitSystem: .metric);
      final imperial = FoodQuantityMode.weight.quantityFor(value: 1, food: egg, unitSystem: .imperial);

      expect(metric?.grams, 100);
      expect(imperial?.grams, closeTo(28.35, 0.01));
    });

    test('only a counted quantity records units, and only a poured one records millilitres', () {
      final egg = FoodFactory.build(gramsPerUnit: 50);
      final weighed = FoodQuantityMode.weight.quantityFor(value: 100, food: egg, unitSystem: .metric);

      expect(weighed?.units, isNull);
      expect(weighed?.milliliters, isNull);
    });
  });

  group('volume', () {
    test("pouring millilitres multiplies by the food's density", () {
      final milk = FoodFactory.build(densityGPerMl: 1.03);

      final quantity = FoodQuantityMode.volume.quantityFor(value: 200, food: milk, unitSystem: .metric);

      expect(quantity?.grams, closeTo(206, 0.01));
      expect(quantity?.milliliters, 200);
      expect(quantity?.units, isNull);
    });

    test('millilitres are recorded in the base unit, not the reader own', () {
      final milk = FoodFactory.build(densityGPerMl: 1);

      final quantity = FoodQuantityMode.volume.quantityFor(value: 1, food: milk, unitSystem: .imperial);

      expect(quantity?.milliliters, closeTo(29.57, 0.01));
      expect(quantity?.grams, closeTo(29.57, 0.01));
    });

    test('pouring a food with no density resolves to no quantity at all', () {
      expect(FoodQuantityMode.volume.quantityFor(value: 200, food: FoodFactory.build(), unitSystem: .metric), isNull);
    });
  });

  group('displayValueFor', () {
    test('reads grams back as the number its own field shows', () {
      final milk = FoodFactory.build(densityGPerMl: 1.03, gramsPerUnit: 250);

      expect(FoodQuantityMode.weight.displayValueFor(grams: 100, food: milk, unitSystem: .metric), 100);
      expect(FoodQuantityMode.units.displayValueFor(grams: 500, food: milk, unitSystem: .metric), 2);
      expect(FoodQuantityMode.volume.displayValueFor(grams: 206, food: milk, unitSystem: .metric), closeTo(200, 0.01));
    });

    test('round-trips through quantityFor', () {
      final milk = FoodFactory.build(densityGPerMl: 1.03);

      final quantity = FoodQuantityMode.volume.quantityFor(value: 350, food: milk, unitSystem: .metric)!;

      expect(FoodQuantityMode.volume.displayValueFor(grams: quantity.grams, food: milk, unitSystem: .metric), closeTo(350, 0.01));
    });

    test('a mode the food cannot be measured in reads back as nothing', () {
      final rice = FoodFactory.build();

      expect(FoodQuantityMode.volume.displayValueFor(grams: 100, food: rice, unitSystem: .metric), isNull);
      expect(FoodQuantityMode.units.displayValueFor(grams: 100, food: rice, unitSystem: .metric), isNull);
    });
  });
}
