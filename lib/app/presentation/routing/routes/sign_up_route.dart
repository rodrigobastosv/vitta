import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/auth/sign_up_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class SignUpRoute extends VTRoute {
  @override
  AppRoute get route => .signUp;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const SignUpPage();
}
