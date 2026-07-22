import 'package:vitta/app/core/services/logging/app_event.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';

abstract class Log {
  static LoggingService service = LoggingService(destinations: const []);

  // The event is an AppEvent rather than a raw string, so the catalog is one
  // file and a typo can't quietly start a second GA4 event. The unwrapping
  // happens here, the way SupabaseService.from unwraps a SupabaseTable, leaving
  // LoggingService a generic sink that knows nothing about the app's events.
  static void action(AppEvent event, {Map<String, Object?> data = const {}}) => service.logAction(event.wireName, data: data);

  static void navigation({required String action, required String route}) => service.logNavigation(action: action, route: route);
}
