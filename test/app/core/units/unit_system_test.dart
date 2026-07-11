import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';

void main() {
  test('fromWireValue parses the persisted wire value back into a UnitSystem', () {
    expect(UnitSystem.fromWireValue('metric'), UnitSystem.metric);
    expect(UnitSystem.fromWireValue('imperial'), UnitSystem.imperial);
  });

  test('metric keeps grams as-is', () {
    expect(UnitSystem.metric.gramsToDisplayWeight(150), 150);
    expect(UnitSystem.metric.displayWeightToGrams(150), 150);
    expect(UnitSystem.metric.weightUnitLabel, 'g');
  });

  test('imperial converts between grams and ounces', () {
    expect(UnitSystem.imperial.gramsToDisplayWeight(28.3495), closeTo(1, 0.001));
    expect(UnitSystem.imperial.displayWeightToGrams(1), closeTo(28.3495, 0.001));
    expect(UnitSystem.imperial.weightUnitLabel, 'oz');
  });

  test('grams round-trip through a display conversion and back', () {
    const grams = 237.0;
    final displayValue = UnitSystem.imperial.gramsToDisplayWeight(grams);

    expect(UnitSystem.imperial.displayWeightToGrams(displayValue), closeTo(grams, 0.001));
  });
}
