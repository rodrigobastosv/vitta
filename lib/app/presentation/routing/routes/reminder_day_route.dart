import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/reminder_day/reminder_day_extra.dart';
import 'package:vitta/app/presentation/pages/reminder_day/reminder_day_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ReminderDayRoute extends VTRoute {
  @override
  AppRoute get route => .reminderDay;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra! as ReminderDayExtra;
    return ReminderDayPage(date: extra.date, reminders: extra.reminders);
  };
}
