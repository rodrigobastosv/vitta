import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/logging/analytics_log_destination.dart';
import 'package:vitta/app/core/services/logging/log_entry.dart';

import '../../../../mocks/services_mocks.dart';

void main() {
  test('an action entry becomes an analytics event carrying its data', () {
    final analyticsService = MockAnalyticsService();

    AnalyticsLogDestination(analyticsService: analyticsService).log(const LogEntry(category: 'action', message: 'food_logged', data: {'meal': 'lunch'}));

    verify(() => analyticsService.logEvent('food_logged', parameters: {'meal': 'lunch'})).called(1);
  });

  test('a push becomes a screen view', () {
    final analyticsService = MockAnalyticsService();

    AnalyticsLogDestination(
      analyticsService: analyticsService,
    ).log(const LogEntry(category: 'navigation', message: 'push diet', data: {'action': 'push', 'route': 'diet'}));

    verify(() => analyticsService.logScreenView('diet')).called(1);
  });

  test('a replace becomes a screen view too', () {
    final analyticsService = MockAnalyticsService();

    AnalyticsLogDestination(
      analyticsService: analyticsService,
    ).log(const LogEntry(category: 'navigation', message: 'replace home', data: {'action': 'replace', 'route': 'home'}));

    verify(() => analyticsService.logScreenView('home')).called(1);
  });

  test('a reveal becomes a screen view, so a screen returned to is counted', () {
    final analyticsService = MockAnalyticsService();

    AnalyticsLogDestination(
      analyticsService: analyticsService,
    ).log(const LogEntry(category: 'navigation', message: 'reveal home', data: {'action': 'reveal', 'route': 'home'}));

    verify(() => analyticsService.logScreenView('home')).called(1);
  });

  test('a pop is not a screen view - it names the screen being left', () {
    final analyticsService = MockAnalyticsService();

    AnalyticsLogDestination(
      analyticsService: analyticsService,
    ).log(const LogEntry(category: 'navigation', message: 'pop diet', data: {'action': 'pop', 'route': 'diet'}));

    verifyNever(() => analyticsService.logScreenView(any()));
    verifyNever(() => analyticsService.logEvent(any(), parameters: any(named: 'parameters')));
  });

  test('a navigation entry with no route reports nothing', () {
    final analyticsService = MockAnalyticsService();

    AnalyticsLogDestination(analyticsService: analyticsService).log(const LogEntry(category: 'navigation', message: 'push'));

    verifyNever(() => analyticsService.logScreenView(any()));
  });
}
