import 'package:flutter/foundation.dart';
import 'package:vitta/app/core/services/logging/log_destination.dart';
import 'package:vitta/app/core/services/logging/log_entry.dart';

class ConsoleLogDestination implements LogDestination {
  const ConsoleLogDestination();

  @override
  void log(LogEntry entry) {
    if (!kDebugMode) {
      return;
    }
    final data = entry.data.isEmpty ? '' : ' ${entry.data}';
    debugPrint('[Vitta.${entry.category}] ${entry.message}$data');
  }
}
