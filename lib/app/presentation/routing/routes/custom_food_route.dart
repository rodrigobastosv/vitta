import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class CustomFoodRoute extends VTRoute {
  @override
  AppRoute get route => .customFood;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const CustomFoodPage();
}
