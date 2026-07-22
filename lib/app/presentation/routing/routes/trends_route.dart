import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/trends/trends_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class TrendsRoute extends VTRoute {
  @override
  AppRoute get route => .trends;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const TrendsPage();
}
