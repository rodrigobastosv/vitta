import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/profile/profile_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ProfileRoute extends VTRoute {
  @override
  AppRoute get route => .profile;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const ProfilePage();
}
