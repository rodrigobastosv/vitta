import 'package:go_router/go_router.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/routes/auth_route.dart';
import 'package:vitta/app/presentation/routing/routes/diet_route.dart';
import 'package:vitta/app/presentation/routing/routes/food_search_route.dart';
import 'package:vitta/app/presentation/routing/routes/home_route.dart';
import 'package:vitta/app/presentation/routing/routes/macro_goals_route.dart';
import 'package:vitta/app/presentation/routing/routes/onboarding_route.dart';
import 'package:vitta/app/presentation/routing/routes/profile_route.dart';
import 'package:vitta/app/presentation/routing/routes/settings_route.dart';
import 'package:vitta/app/presentation/routing/routes/sleep_route.dart';
import 'package:vitta/app/presentation/routing/routes/water_route.dart';
import 'package:vitta/app/presentation/routing/routes/workout_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

abstract class AppRouter {
  static final List<VTRoute> _routes = [
    OnboardingRoute(),
    HomeRoute(hasSeenOnboardingUseCase: G()),
    DietRoute(),
    FoodSearchRoute(),
    WaterRoute(),
    SleepRoute(),
    WorkoutRoute(),
    ProfileRoute(),
    MacroGoalsRoute(),
    SettingsRoute(),
    AuthRoute(),
  ];

  static final GoRouter router = GoRouter(initialLocation: AppRoute.home.path, routes: _routes.map((route) => route.toGoRoute()).toList());
}
