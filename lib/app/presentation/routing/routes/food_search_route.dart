import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class FoodSearchRoute extends VTRoute {
  @override
  AppRoute get route => .foodSearch;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const FoodSearchPage();
}
