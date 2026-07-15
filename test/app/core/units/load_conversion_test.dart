import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';

void main() {
  group('LoadConversion', () {
    test('metric passes kilograms through untouched', () {
      expect(UnitSystem.metric.kilogramsToDisplayLoad(60), 60);
      expect(UnitSystem.metric.displayLoadToKilograms(60), 60);
      expect(UnitSystem.metric.loadUnitLabel, 'kg');
    });

    test('imperial converts kilograms to pounds', () {
      expect(UnitSystem.imperial.kilogramsToDisplayLoad(100), closeTo(220.462, 0.001));
      expect(UnitSystem.imperial.loadUnitLabel, 'lb');
    });

    test('round-trips through the display unit without drifting', () {
      final kilograms = UnitSystem.imperial.displayLoadToKilograms(UnitSystem.imperial.kilogramsToDisplayLoad(82.5));

      expect(kilograms, closeTo(82.5, 0.0001));
    });

    test('is independent of the grams/ounces weight conversion, which food quantity uses', () {
      expect(UnitSystem.imperial.weightUnitLabel, 'oz');
      expect(UnitSystem.imperial.loadUnitLabel, 'lb');
    });
  });
}
