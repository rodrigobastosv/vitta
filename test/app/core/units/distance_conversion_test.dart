import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';

void main() {
  group('DistanceConversion', () {
    test('metric shows kilometers', () {
      expect(UnitSystem.metric.metersToDisplayDistance(5000), 5);
      expect(UnitSystem.metric.displayDistanceToMeters(5), 5000);
      expect(UnitSystem.metric.distanceUnitLabel, 'km');
    });

    test('imperial shows miles', () {
      expect(UnitSystem.imperial.metersToDisplayDistance(1609.344), closeTo(1, 0.0001));
      expect(UnitSystem.imperial.distanceUnitLabel, 'mi');
    });

    test('round-trips through the display unit without drifting', () {
      final meters = UnitSystem.imperial.displayDistanceToMeters(UnitSystem.imperial.metersToDisplayDistance(4200));

      expect(meters, closeTo(4200, 0.0001));
    });
  });
}
