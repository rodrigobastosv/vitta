import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_extra.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class MealScanRoute extends VTRoute {
  @override
  AppRoute get route => .mealScan;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => MealScanPage(loggedDate: (state.extra! as MealScanExtra).loggedDate);
}
