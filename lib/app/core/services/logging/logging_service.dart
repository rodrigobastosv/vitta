import 'package:vitta/app/core/services/logging/log_destination.dart';
import 'package:vitta/app/core/services/logging/log_entry.dart';

class LoggingService {
  LoggingService({required this._destinations});

  final List<LogDestination> _destinations;

  void logNavigation({required String action, required String route}) =>
      _dispatch(LogEntry(category: 'navigation', message: '$action $route', data: {'action': action, 'route': route}));

  void logAction(String action, {Map<String, Object?> data = const {}}) =>
      _dispatch(LogEntry(category: 'action', message: action, data: data));

  void _dispatch(LogEntry entry) {
    for (final destination in _destinations) {
      destination.log(entry);
    }
  }
}
