import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class BodyWeightHistoryRoute extends VTRoute {
  @override
  AppRoute get route => .bodyWeightHistory;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const BodyWeightHistoryPage();
}
