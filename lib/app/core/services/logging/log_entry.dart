import 'package:vitta/app/core/services/logging/log_level.dart';

class LogEntry {
  const LogEntry({required this.category, required this.message, this.level = LogLevel.info, this.data = const {}});

  final String category;
  final String message;
  final LogLevel level;
  final Map<String, Object?> data;
}
