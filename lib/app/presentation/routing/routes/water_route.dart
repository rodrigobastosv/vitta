import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/water/water_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class WaterRoute extends VTRoute {
  @override
  AppRoute get route => .water;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const WaterPage();
}
