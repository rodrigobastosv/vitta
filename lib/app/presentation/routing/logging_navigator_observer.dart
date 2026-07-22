import 'package:flutter/material.dart';
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
    // A pop names the screen being left, which leaves the screen being returned
    // to unrecorded - so nothing downstream can tell that Home came back into
    // view. `reveal` is that second half, and it is what AnalyticsLogDestination
    // counts as the screen view (a pop is an exit, not an arrival).
    if (previousRoute != null) {
      _log('reveal', previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _log('replace', newRoute);
    }
  }

  void _log(String action, Route<dynamic> route) {
    Log.navigation(action: action, route: _routeName(route));
  }

  // GoRouter pages carry their AppRoute name; modal sheets and dialogs are
  // launched anonymously (no RouteSettings.name), so they used to all log as
  // "unknown". Fall back to the popup kind instead, which is at least truthful.
  String _routeName(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null) {
      return name;
    }
    return switch (route) {
      ModalBottomSheetRoute() => 'bottomSheet',
      DialogRoute() || RawDialogRoute() => 'dialog',
      PopupRoute() => 'popup',
      _ => 'unknown',
    };
  }
}
