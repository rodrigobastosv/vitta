import 'package:go_router/go_router.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/logging_navigator_observer.dart';
import 'package:vitta/app/presentation/routing/routes/body_weight_history_route.dart';
import 'package:vitta/app/presentation/routing/routes/body_weight_route.dart';
import 'package:vitta/app/presentation/routing/routes/copy_meals_route.dart';
import 'package:vitta/app/presentation/routing/routes/custom_food_route.dart';
import 'package:vitta/app/presentation/routing/routes/diet_day_route.dart';
import 'package:vitta/app/presentation/routing/routes/diet_history_route.dart';
import 'package:vitta/app/presentation/routing/routes/diet_intro_route.dart';
import 'package:vitta/app/presentation/routing/routes/diet_route.dart';
import 'package:vitta/app/presentation/routing/routes/edit_profile_route.dart';
import 'package:vitta/app/presentation/routing/routes/exercise_detail_route.dart';
import 'package:vitta/app/presentation/routing/routes/exercise_progression_list_route.dart';
import 'package:vitta/app/presentation/routing/routes/exercise_progression_route.dart';
import 'package:vitta/app/presentation/routing/routes/exercise_search_route.dart';
import 'package:vitta/app/presentation/routing/routes/food_search_route.dart';
import 'package:vitta/app/presentation/routing/routes/home_route.dart';
import 'package:vitta/app/presentation/routing/routes/ingredient_picker_route.dart';
import 'package:vitta/app/presentation/routing/routes/macro_goals_route.dart';
import 'package:vitta/app/presentation/routing/routes/meal_scan_route.dart';
import 'package:vitta/app/presentation/routing/routes/onboarding_route.dart';
import 'package:vitta/app/presentation/routing/routes/profile_route.dart';
import 'package:vitta/app/presentation/routing/routes/recipe_form_route.dart';
import 'package:vitta/app/presentation/routing/routes/recipes_route.dart';
import 'package:vitta/app/presentation/routing/routes/reminder_history_route.dart';
import 'package:vitta/app/presentation/routing/routes/reminder_route.dart';
import 'package:vitta/app/presentation/routing/routes/routine_form_route.dart';
import 'package:vitta/app/presentation/routing/routes/routines_route.dart';
import 'package:vitta/app/presentation/routing/routes/settings_route.dart';
import 'package:vitta/app/presentation/routing/routes/sign_in_route.dart';
import 'package:vitta/app/presentation/routing/routes/sign_up_route.dart';
import 'package:vitta/app/presentation/routing/routes/sleep_history_route.dart';
import 'package:vitta/app/presentation/routing/routes/sleep_route.dart';
import 'package:vitta/app/presentation/routing/routes/water_history_route.dart';
import 'package:vitta/app/presentation/routing/routes/water_route.dart';
import 'package:vitta/app/presentation/routing/routes/workout_history_route.dart';
import 'package:vitta/app/presentation/routing/routes/workout_intro_route.dart';
import 'package:vitta/app/presentation/routing/routes/workout_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

abstract class AppRouter {
  static final List<VTRoute> _routes = [
    OnboardingRoute(),
    HomeRoute(hasSeenOnboardingUseCase: G()),
    DietRoute(),
    DietIntroRoute(),
    CopyMealsRoute(),
    MealScanRoute(),
    DietHistoryRoute(),
    DietDayRoute(),
    RecipesRoute(),
    RecipeFormRoute(),
    IngredientPickerRoute(),
    FoodSearchRoute(),
    CustomFoodRoute(),
    WaterRoute(),
    WaterHistoryRoute(),
    BodyWeightRoute(),
    BodyWeightHistoryRoute(),
    SleepRoute(),
    SleepHistoryRoute(),
    ReminderRoute(),
    ReminderHistoryRoute(),
    WorkoutRoute(),
    WorkoutIntroRoute(),
    WorkoutHistoryRoute(),
    RoutinesRoute(),
    RoutineFormRoute(),
    ExerciseSearchRoute(),
    ExerciseDetailRoute(),
    ExerciseProgressionListRoute(),
    ExerciseProgressionRoute(),
    ProfileRoute(),
    EditProfileRoute(),
    MacroGoalsRoute(),
    SettingsRoute(),
    SignInRoute(),
    SignUpRoute(),
  ];

  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.home.path,
    observers: [LoggingNavigatorObserver()],
    routes: _routes.map((route) => route.toGoRoute()).toList(),
  );
}
