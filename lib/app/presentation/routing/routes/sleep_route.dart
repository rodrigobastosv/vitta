import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class SleepRoute extends VTRoute {
  @override
  AppRoute get route => .sleep;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const SleepPage();
}
