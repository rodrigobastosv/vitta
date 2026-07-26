import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_extra.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class MealSuggestionRoute extends VTRoute {
  @override
  AppRoute get route => .mealSuggestion;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => MealSuggestionPage(loggedDate: (state.extra! as MealSuggestionExtra).loggedDate);
}
