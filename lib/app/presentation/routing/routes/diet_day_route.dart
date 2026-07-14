import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/diet_day/diet_day_extra.dart';
import 'package:vitta/app/presentation/pages/diet_day/diet_day_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class DietDayRoute extends VTRoute {
  @override
  AppRoute get route => .dietDay;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra! as DietDayExtra;
    return DietDayPage(date: extra.date, dailyMacros: extra.dailyMacros, macroGoals: extra.macroGoals);
  };
}
