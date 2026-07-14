import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/logging/log_entry.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';

import '../../../../mocks/services_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(const LogEntry(category: 'fallback', message: 'fallback')));

  test('logNavigation dispatches a navigation entry to every destination', () {
    final destinationA = MockLogDestination();
    final destinationB = MockLogDestination();
    final loggingService = LoggingService(destinations: [destinationA, destinationB]);

    loggingService.logNavigation(action: 'push', route: 'diet');

    final entryA = verify(() => destinationA.log(captureAny())).captured.single as LogEntry;
    expect(entryA.category, 'navigation');
    expect(entryA.data, {'action': 'push', 'route': 'diet'});
    verify(() => destinationB.log(any())).called(1);
  });

  test('logAction dispatches an action entry with its data', () {
    final destination = MockLogDestination();
    final loggingService = LoggingService(destinations: [destination]);

    loggingService.logAction('food_logged', data: {'food': 'Banana'});

    final entry = verify(() => destination.log(captureAny())).captured.single as LogEntry;
    expect(entry.category, 'action');
    expect(entry.message, 'food_logged');
    expect(entry.data, {'food': 'Banana'});
  });
}
