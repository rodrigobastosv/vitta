import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/auth/auth_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class AuthRoute extends VTRoute {
  @override
  AppRoute get route => .auth;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const AuthPage();
}
