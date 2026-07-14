import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class DietHistoryRoute extends VTRoute {
  @override
  AppRoute get route => .dietHistory;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const DietHistoryPage();
}
