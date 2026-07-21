import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_extra.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class AddFoodRoute extends VTRoute {
  @override
  AppRoute get route => .addFood;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra! as AddFoodExtra;
    return AddFoodPage(loggedDate: extra.loggedDate, initialMealType: extra.initialMealType);
  };
}
