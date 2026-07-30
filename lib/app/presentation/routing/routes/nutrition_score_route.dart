import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/nutrition_score/nutrition_score_extra.dart';
import 'package:vitta/app/presentation/pages/nutrition_score/nutrition_score_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class NutritionScoreRoute extends VTRoute {
  @override
  AppRoute get route => .nutritionScore;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra! as NutritionScoreExtra;
    return NutritionScorePage(date: extra.date, dailyMacros: extra.dailyMacros, macroGoals: extra.macroGoals);
  };
}
