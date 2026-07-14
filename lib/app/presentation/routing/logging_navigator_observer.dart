import 'package:flutter/widgets.dart';
import 'package:vitta/app/core/services/logging/log.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _log('replace', newRoute);
    }
  }

  void _log(String action, Route<dynamic> route) {
    Log.navigation(action: action, route: route.settings.name ?? 'unknown');
  }
}
