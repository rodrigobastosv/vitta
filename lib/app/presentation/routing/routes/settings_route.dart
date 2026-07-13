import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/settings/settings_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class SettingsRoute extends VTRoute {
  @override
  AppRoute get route => .settings;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const SettingsPage();
}
