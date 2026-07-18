import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ReminderRoute extends VTRoute {
  @override
  AppRoute get route => .reminders;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const ReminderPage();
}
