import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class RecipeFormRoute extends VTRoute {
  @override
  AppRoute get route => .recipeForm;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const RecipeFormPage();
}
