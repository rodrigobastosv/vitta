import 'package:vitta/app/core/services/analytics/analytics_service.dart';
import 'package:vitta/app/core/services/logging/log_destination.dart';
import 'package:vitta/app/core/services/logging/log_entry.dart';

/// Forwards every `Log.action` / `Log.navigation` to Google Analytics.
///
/// This is the sink the logging service was built for: the 51 call sites that
/// already name a `snake_case` event were instrumented for Sentry breadcrumbs
/// and the console, and adding analytics costs one destination in the list
/// rather than an analytics call beside each of them.
class AnalyticsLogDestination implements LogDestination {
  const AnalyticsLogDestination({required this._analyticsService});

  final AnalyticsService _analyticsService;

  // Every LogDestination is fire-and-forget (`void log`), and analytics is the
  // one that does real I/O - so the future is deliberately not awaited. A failed
  // report must not stall the action that produced it, and there is nothing the
  // app would do with the error anyway.
  @override
  void log(LogEntry entry) {
    if (entry.category == 'navigation') {
      _logNavigation(entry);
      return;
    }
    _analyticsService.logEvent(entry.message, parameters: entry.data);
  }

  // A screen view is an *arrival*, so a pop is skipped and the `reveal` the
  // observer emits alongside it - naming the screen being returned to - is what
  // counts instead. Logging the popped route here would credit the view to the
  // screen the user just left.
  void _logNavigation(LogEntry entry) {
    if (entry.data['action'] == 'pop') {
      return;
    }
    final route = entry.data['route'];
    if (route is! String) {
      return;
    }
    _analyticsService.logScreenView(route);
  }
}
