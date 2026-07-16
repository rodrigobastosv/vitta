import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class RecipesRoute extends VTRoute {
  @override
  AppRoute get route => .recipes;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const RecipesPage();
}
