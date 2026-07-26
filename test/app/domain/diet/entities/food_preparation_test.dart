import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_preparation.dart';

void main() {
  test('round-trips through its wire value', () {
    for (final preparation in FoodPreparation.values) {
      expect(FoodPreparation.fromWireValue(preparation.wireValue), preparation);
    }
  });

  // A food with no cooking step has no preparation, and an importer may write a
  // value the app does not model yet - both read as "not stated" rather than
  // throwing, the way FoodCategory.fromWireValue does.
  test('an absent or unknown wire value reads as not stated', () {
    expect(FoodPreparation.fromWireValue(null), isNull);
    expect(FoodPreparation.fromWireValue('steamed'), isNull);
    expect(FoodPreparation.fromWireValue(''), isNull);
  });
}
