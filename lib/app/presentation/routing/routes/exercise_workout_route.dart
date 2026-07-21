import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ExerciseWorkoutRoute extends VTRoute {
  @override
  AppRoute get route => .exerciseWorkout;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => ExerciseWorkoutPage(extra: state.extra! as ExerciseWorkoutExtra);
}
