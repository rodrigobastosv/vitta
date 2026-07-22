import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/presentation/general/workout_duration_format.dart';
import 'package:vitta/l10n/arb/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('formatWorkoutDuration', () {
    test('whole minutes read as minutes', () {
      expect(formatWorkoutDuration(l10n, 1500), '25 min');
    });

    test('minutes and seconds read together', () {
      expect(formatWorkoutDuration(l10n, 1530), '25m 30s');
    });

    test('an hour or more reads as hours and minutes', () {
      expect(formatWorkoutDuration(l10n, 3900), '1h 5min');
    });

    test('under a minute reads as seconds', () {
      expect(formatWorkoutDuration(l10n, 45), '45 s');
    });
  });

  group('formatWorkoutDistance', () {
    test('metric renders kilometers', () {
      expect(formatWorkoutDistance(UnitSystem.metric, 5000), '5 km');
      expect(formatWorkoutDistance(UnitSystem.metric, 5500), '5.5 km');
    });

    test('imperial renders miles', () {
      expect(formatWorkoutDistance(UnitSystem.imperial, 1609.344), '1 mi');
    });
  });
}
