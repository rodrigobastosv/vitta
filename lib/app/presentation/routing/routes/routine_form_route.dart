import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_extra.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class RoutineFormRoute extends VTRoute {
  @override
  AppRoute get route => .routineForm;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra as RoutineFormExtra?;
    return RoutineFormPage(routine: extra?.routine);
  };
}
