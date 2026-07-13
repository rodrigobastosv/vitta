import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

void main() {
  test('fromWireKey resolves a known key and returns null for an unknown one', () {
    expect(Nutrient.fromWireKey('vitamin_c'), Nutrient.vitaminC);
    expect(Nutrient.fromWireKey('made_up_nutrient'), isNull);
  });

  test('every nutrient has a unique wireKey and offKey', () {
    expect(Nutrient.values.map((nutrient) => nutrient.wireKey).toSet(), hasLength(Nutrient.values.length));
    expect(Nutrient.values.map((nutrient) => nutrient.offKey).toSet(), hasLength(Nutrient.values.length));
  });

  test('unit converts grams to its display unit', () {
    expect(NutrientUnit.milligram.fromGrams(0.5), 500);
    expect(NutrientUnit.microgram.fromGrams(0.001), 1000);
  });
}
