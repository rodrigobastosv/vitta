import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

void main() {
  test('every case round-trips through its wire value', () {
    for (final source in FoodSource.values) {
      expect(FoodSource.fromWireValue(source.wireValue), source);
    }
  });

  test('generic maps to its wire value', () {
    expect(FoodSource.generic.wireValue, 'generic');
    expect(FoodSource.fromWireValue('generic'), FoodSource.generic);
  });

  test('fromWireValue throws on an unknown source', () {
    expect(() => FoodSource.fromWireValue('mystery'), throwsArgumentError);
  });
}
