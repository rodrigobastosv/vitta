import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/rest_timer_settings/rest_timer_settings_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class RestTimerSettingsRoute extends VTRoute {
  @override
  AppRoute get route => .restTimerSettings;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const RestTimerSettingsPage();
}
