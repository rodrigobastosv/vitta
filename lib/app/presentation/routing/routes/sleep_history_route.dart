import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class SleepHistoryRoute extends VTRoute {
  @override
  AppRoute get route => .sleepHistory;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const SleepHistoryPage();
}
