import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class BodyWeightRoute extends VTRoute {
  @override
  AppRoute get route => .bodyWeight;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const BodyWeightPage();
}
