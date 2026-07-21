import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class WorkoutHistoryRoute extends VTRoute {
  @override
  AppRoute get route => .workoutHistory;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const WorkoutHistoryPage();
}
