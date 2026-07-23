import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';

import '../mocks/services_mocks.dart';

MockNotificationService registerTestNotificationService() {
  registerFallbackValue(DateTime(2000));
  final notificationService = MockNotificationService();
  when(notificationService.requestPermission).thenAnswer((_) async => true);
  when(() => notificationService.cancel(any())).thenAnswer((_) async {});
  when(notificationService.cancelAll).thenAnswer((_) async {});
  when(
    () => notificationService.scheduleReminder(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      dateTime: any(named: 'dateTime'),
    ),
  ).thenAnswer((_) async {});
  if (G.isRegistered<NotificationService>()) {
    G.unregister<NotificationService>();
  }
  G.registerSingleton<NotificationService>(notificationService);
  return notificationService;
}
