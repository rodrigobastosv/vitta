import 'package:vitta/app/core/services/logging/logging_service.dart';

abstract class Log {
  static LoggingService service = LoggingService(destinations: const []);

  static void action(String action, {Map<String, Object?> data = const {}}) => service.logAction(action, data: data);

  static void navigation({required String action, required String route}) => service.logNavigation(action: action, route: route);
}
