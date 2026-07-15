import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/exercise_detail/exercise_detail_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_detail/exercise_detail_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ExerciseDetailRoute extends VTRoute {
  @override
  AppRoute get route => .exerciseDetail;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra! as ExerciseDetailExtra;
    return ExerciseDetailPage(exercise: extra.exercise);
  };
}
