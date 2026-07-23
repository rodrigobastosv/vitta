import 'package:flutter/widgets.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/presentation/routing/app_router.dart';
import 'package:vitta/app/presentation/routing/notification_route.dart';

/// Takes a tapped notification to the page it is about. It is wiring, not a
/// page, so it sits outside the widget tree and is started from `bootstrap` -
/// the same place `HomeRoute`'s onboarding gate is resolved from.
abstract class NotificationNavigator {
  static Future<void> start(NotificationService notificationService) async {
    notificationService.taps.listen(_open);
    final launchPayload = await notificationService.launchPayload();
    if (launchPayload == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _open(launchPayload));
  }

  static void _open(String payload) {
    final route = notificationRouteFor(payload);
    if (route != null) {
      AppRouter.router.push(route.path);
    }
  }
}
