import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';

abstract class VTRoute {
  AppRoute get route;

  GoRouterWidgetBuilder get builder;

  GoRouterRedirect? get redirect => null;

  GoRoute toGoRoute() => GoRoute(path: route.path, name: route.name, builder: builder, redirect: redirect);
}
