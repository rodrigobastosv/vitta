import 'package:go_router/go_router.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/data/onboarding/onboarding_repository.dart';
import 'package:vitta/app/presentation/pages/diet/diet_page.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_page.dart';
import 'package:vitta/app/presentation/pages/home/home_page.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_page.dart';
import 'package:vitta/app/presentation/pages/settings/settings_page.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_page.dart';
import 'package:vitta/app/presentation/pages/water/water_page.dart';
import 'package:vitta/app/presentation/pages/workout/workout_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.home.path,
    redirect: (context, state) {
      final hasSeenOnboarding = G<OnboardingRepository>().hasSeenOnboarding();
      final isGoingToOnboarding = state.matchedLocation == AppRoute.onboarding.path;
      if (!hasSeenOnboarding && !isGoingToOnboarding) {
        return AppRoute.onboarding.path;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: AppRoute.home.path, name: AppRoute.home.name, builder: (context, state) => const HomePage()),
      GoRoute(path: AppRoute.diet.path, name: AppRoute.diet.name, builder: (context, state) => const DietPage()),
      GoRoute(path: AppRoute.foodSearch.path, name: AppRoute.foodSearch.name, builder: (context, state) => const FoodSearchPage()),
      GoRoute(path: AppRoute.water.path, name: AppRoute.water.name, builder: (context, state) => const WaterPage()),
      GoRoute(path: AppRoute.sleep.path, name: AppRoute.sleep.name, builder: (context, state) => const SleepPage()),
      GoRoute(path: AppRoute.workout.path, name: AppRoute.workout.name, builder: (context, state) => const WorkoutPage()),
      GoRoute(path: AppRoute.settings.path, name: AppRoute.settings.name, builder: (context, state) => const SettingsPage()),
    ],
  );
}
