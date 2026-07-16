import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ExerciseProgressionListRoute extends VTRoute {
  @override
  AppRoute get route => .exerciseProgressionList;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const ExerciseProgressionListPage();
}
