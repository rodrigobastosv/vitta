import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/auth/sign_in_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class SignInRoute extends VTRoute {
  @override
  AppRoute get route => .signIn;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const SignInPage();
}
