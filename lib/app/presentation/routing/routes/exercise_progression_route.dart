import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ExerciseProgressionRoute extends VTRoute {
  @override
  AppRoute get route => .exerciseProgression;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra! as ExerciseProgressionExtra;
    return ExerciseProgressionPage(exercise: extra.exercise);
  };
}
