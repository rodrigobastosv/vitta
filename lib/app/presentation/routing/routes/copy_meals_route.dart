import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_extra.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class CopyMealsRoute extends VTRoute {
  @override
  AppRoute get route => .copyMeals;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => CopyMealsPage(targetDate: (state.extra! as CopyMealsExtra).targetDate);
}
