import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/routines/routines_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class RoutinesRoute extends VTRoute {
  @override
  AppRoute get route => .routines;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const RoutinesPage();
}
