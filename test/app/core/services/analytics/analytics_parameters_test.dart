import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/services/analytics/analytics_parameters.dart';

void main() {
  group('eventName', () {
    test('keeps a snake_case name as it is', () {
      expect(AnalyticsParameters.eventName('food_logged'), 'food_logged');
    });

    test('folds anything GA4 rejects to an underscore', () {
      expect(AnalyticsParameters.eventName('Food.Logged-Today'), 'food_logged_today');
    });

    test('strips a reserved prefix rather than shipping an event GA4 discards', () {
      expect(AnalyticsParameters.eventName('firebase_food_logged'), 'food_logged');
      expect(AnalyticsParameters.eventName('ga_session'), 'session');
    });

    test('drops leading non-letters, since a name must start with a letter', () {
      expect(AnalyticsParameters.eventName('_2_meals_copied'), 'meals_copied');
    });

    test('truncates to the event name limit', () {
      final name = AnalyticsParameters.eventName('a' * 60);
      expect(name.length, AnalyticsParameters.maxEventNameLength);
    });

    test('falls back to a placeholder when nothing usable survives', () {
      expect(AnalyticsParameters.eventName('123'), 'unnamed_event');
    });
  });

  group('screenName', () {
    test('keeps camelCase, since a screen name is a label and not an identifier', () {
      expect(AnalyticsParameters.screenName('foodSearch'), 'foodSearch');
    });

    test('truncates to the parameter value limit', () {
      expect(AnalyticsParameters.screenName('a' * 200).length, AnalyticsParameters.maxParameterValueLength);
    });
  });

  group('sanitize', () {
    test('passes numbers through untouched', () {
      expect(AnalyticsParameters.sanitize({'calories': 320, 'grams': 12.5}), {'calories': 320, 'grams': 12.5});
    });

    test('stringifies a bool, which GA4 cannot represent', () {
      expect(AnalyticsParameters.sanitize({'is_premium': true}), {'is_premium': 'true'});
    });

    test('drops a null value rather than inventing one for it', () {
      expect(AnalyticsParameters.sanitize({'brand': null, 'food': 'Banana'}), {'food': 'Banana'});
    });

    test('truncates a long string value', () {
      final sanitized = AnalyticsParameters.sanitize({'note': 'x' * 200});
      expect((sanitized['note']! as String).length, AnalyticsParameters.maxParameterValueLength);
    });

    test('sanitizes parameter names the same way event names are', () {
      expect(AnalyticsParameters.sanitize({'Meal Type': 'lunch'}), {'meal_type': 'lunch'});
    });

    test('caps the parameter count, since a 26th parameter drops the whole event', () {
      final data = {for (var index = 0; index < 40; index++) 'p$index': index};

      expect(AnalyticsParameters.sanitize(data).length, AnalyticsParameters.maxParameterCount);
    });
  });
}
