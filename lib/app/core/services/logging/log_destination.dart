import 'package:vitta/app/core/services/logging/log_entry.dart';

abstract class LogDestination {
  void log(LogEntry entry);
}
