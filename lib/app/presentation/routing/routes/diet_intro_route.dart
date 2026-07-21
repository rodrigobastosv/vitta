import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/diet/diet_intro_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class DietIntroRoute extends VTRoute {
  @override
  AppRoute get route => .dietIntro;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const DietIntroPage();
}
