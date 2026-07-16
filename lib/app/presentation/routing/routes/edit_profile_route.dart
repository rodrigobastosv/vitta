import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/profile/edit_profile_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class EditProfileRoute extends VTRoute {
  @override
  AppRoute get route => .editProfile;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const EditProfilePage();
}
