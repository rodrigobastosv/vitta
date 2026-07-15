import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class WaterHistoryRoute extends VTRoute {
  @override
  AppRoute get route => .waterHistory;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const WaterHistoryPage();
}
