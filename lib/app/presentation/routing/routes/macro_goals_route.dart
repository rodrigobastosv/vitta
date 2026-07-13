import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class MacroGoalsRoute extends VTRoute {
  @override
  AppRoute get route => .macroGoals;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const MacroGoalsPage();
}
