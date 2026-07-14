import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vitta/app/core/services/logging/log_destination.dart';
import 'package:vitta/app/core/services/logging/log_entry.dart';
import 'package:vitta/app/core/services/logging/log_level.dart';

class SentryLogDestination implements LogDestination {
  const SentryLogDestination();

  @override
  void log(LogEntry entry) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: entry.message,
        category: entry.category,
        level: _sentryLevel(entry.level),
        data: entry.data.isEmpty ? null : Map<String, dynamic>.from(entry.data),
      ),
    );
  }

  SentryLevel _sentryLevel(LogLevel level) => switch (level) {
    .info => SentryLevel.info,
    .warning => SentryLevel.warning,
    .error => SentryLevel.error,
  };
}
