import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/initial_food_quantity.dart';

import '../../../../../factories/entities/food_factory.dart';

void main() {
  test('a countable food opens at one item, not at a weight', () {
    final quantity = initialFoodQuantityFor(FoodFactory.build(gramsPerUnit: 50));

    expect(quantity.units, 1);
    expect(quantity.grams, 50);
  });

  test('a liquid opens at one glass', () {
    final quantity = initialFoodQuantityFor(FoodFactory.build(densityGPerMl: 1.03));

    expect(quantity.milliliters, 200);
    expect(quantity.grams, closeTo(206, 0.01));
  });

  test('everything else opens at the hundred grams its macros are stated for', () {
    final quantity = initialFoodQuantityFor(FoodFactory.build());

    expect(quantity.grams, 100);
    expect(quantity.units, isNull);
    expect(quantity.milliliters, isNull);
  });

  // A canned drink is both, and counting it is the fewer taps - the same "a
  // countable food leads with the unit" call issue #143 made.
  test('a food that is both countable and a liquid leads with the count', () {
    final quantity = initialFoodQuantityFor(FoodFactory.build(gramsPerUnit: 364, densityGPerMl: 1.04));

    expect(quantity.units, 1);
    expect(quantity.grams, 364);
    expect(quantity.milliliters, isNull);
  });
}
