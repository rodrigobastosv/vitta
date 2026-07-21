import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/workout/workout_intro_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class WorkoutIntroRoute extends VTRoute {
  @override
  AppRoute get route => .workoutIntro;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const WorkoutIntroPage();
}
