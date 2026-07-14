import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';

import '../mocks/services_mocks.dart';

MockLoggingService useMockLog() {
  final loggingService = MockLoggingService();
  Log.service = loggingService;
  addTearDown(() => Log.service = LoggingService(destinations: const []));
  return loggingService;
}
