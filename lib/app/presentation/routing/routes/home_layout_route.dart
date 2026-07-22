import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class HomeLayoutRoute extends VTRoute {
  @override
  AppRoute get route => .homeLayout;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const HomeLayoutPage();
}
