import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/workout/workout_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class WorkoutRoute extends VTRoute {
  @override
  AppRoute get route => .workout;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const WorkoutPage();
}
