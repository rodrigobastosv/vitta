import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class LogRemindersRoute extends VTRoute {
  @override
  AppRoute get route => .logReminders;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const LogRemindersPage();
}
