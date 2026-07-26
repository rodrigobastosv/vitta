import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';

import '../../../../factories/entities/food_log_factory.dart';

void main() {
  test('a weight records neither a count nor a volume', () {
    const quantity = LoggedQuantity.weight(250);

    expect(quantity.grams, 250);
    expect(quantity.units, isNull);
    expect(quantity.milliliters, isNull);
  });

  test('a count records the count alongside the grams it resolved to', () {
    const quantity = LoggedQuantity.units(units: 2, grams: 100);

    expect(quantity.grams, 100);
    expect(quantity.units, 2);
    expect(quantity.milliliters, isNull);
  });

  test('a volume records the millilitres alongside the grams it resolved to', () {
    const quantity = LoggedQuantity.volume(milliliters: 200, grams: 206);

    expect(quantity.grams, 206);
    expect(quantity.milliliters, 200);
    expect(quantity.units, isNull);
  });

  group('fromLog', () {
    test('reads a counted log back as a count', () {
      final quantity = LoggedQuantity.fromLog(FoodLogFactory.build(quantityUnits: 2));

      expect(quantity, const LoggedQuantity.units(units: 2, grams: 100));
    });

    test('reads a poured log back as a volume', () {
      final quantity = LoggedQuantity.fromLog(FoodLogFactory.build(quantityGrams: 206, quantityMl: 200));

      expect(quantity, const LoggedQuantity.volume(milliliters: 200, grams: 206));
    });

    test('reads a weighed log back as a weight', () {
      final quantity = LoggedQuantity.fromLog(FoodLogFactory.build(quantityGrams: 150));

      expect(quantity, const LoggedQuantity.weight(150));
    });

    // The two are mutually exclusive in the database (food_logs_quantity_shape),
    // so this only pins which one wins if a row ever slips past that constraint.
    test('prefers the count when a log somehow carries both', () {
      final quantity = LoggedQuantity.fromLog(FoodLogFactory.build(quantityUnits: 2, quantityMl: 90));

      expect(quantity.units, 2);
      expect(quantity.milliliters, isNull);
    });
  });

  test('compares by value, so a cubit test can verify a logged quantity', () {
    expect(const LoggedQuantity.weight(100), const LoggedQuantity.weight(100));
    expect(const LoggedQuantity.weight(100), isNot(const LoggedQuantity.units(units: 1, grams: 100)));
  });
}
