import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/objective/objective_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ObjectiveRoute extends VTRoute {
  @override
  AppRoute get route => .objective;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const ObjectivePage();
}
