import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_extra.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class WorkoutSummaryRoute extends VTRoute {
  @override
  AppRoute get route => .workoutSummary;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => WorkoutSummaryPage(extra: state.extra! as WorkoutSummaryExtra);
}
