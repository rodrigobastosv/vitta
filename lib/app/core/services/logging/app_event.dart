/// Every action the app reports, pairing the Dart case with the `snake_case`
/// name that reaches Sentry's breadcrumbs and GA4 - the way `SupabaseTable`
/// pairs a case with its DB name and `MealType` with its wire value.
///
/// The wire names are the analytics contract: a GA4 funnel is keyed on the
/// string, so renaming one here starts a brand new event and orphans every
/// figure recorded under the old name. `app_event_test.dart` pins all of them
/// against a literal list for exactly that reason, and also asserts each is
/// already GA4-legal so `AnalyticsParameters.eventName` never has to alter one.
///
/// Adding an event is one case here plus the `Log.action(.newCase)` on the
/// cubit's success path - no new mechanism, and the catalog stays readable in
/// one file rather than being spread across 50-odd string literals.
enum AppEvent {
  signIn('sign_in'),
  signUp('sign_up'),
  signOut('sign_out'),
  accountDeleted('account_deleted'),
  profileUpdated('profile_updated'),

  onboardingCompleted('onboarding_completed'),
  onboardingGoalsSet('onboarding_goals_set'),
  onboardingWeightLogged('onboarding_weight_logged'),
  objectiveChanged('objective_changed'),

  themeChanged('theme_changed'),
  localeChanged('locale_changed'),
  unitSystemChanged('unit_system_changed'),

  foodLogged('food_logged'),
  foodLogUpdated('food_log_updated'),
  foodLogDeleted('food_log_deleted'),
  foodFavorited('food_favorited'),
  foodUnfavorited('food_unfavorited'),
  mealLoggedFromScan('meal_logged_from_scan'),
  mealsCopied('meals_copied'),
  macroGoalsSaved('macro_goals_saved'),

  recipeCreated('recipe_created'),
  recipeUpdated('recipe_updated'),
  recipeDeleted('recipe_deleted'),

  waterLogged('water_logged'),
  waterLogDeleted('water_log_deleted'),
  waterGoalChanged('water_goal_changed'),

  sleepLogged('sleep_logged'),
  sleepLogDeleted('sleep_log_deleted'),
  sleepImportedFromHealth('sleep_imported_from_health'),

  bodyWeightLogged('body_weight_logged'),
  bodyWeightLogDeleted('body_weight_log_deleted'),

  progressPhotoAdded('progress_photo_added'),
  progressPhotoDeleted('progress_photo_deleted'),

  reminderCreated('reminder_created'),
  reminderCompleted('reminder_completed'),
  reminderDeleted('reminder_deleted'),

  workoutStartedFromRoutine('workout_started_from_routine'),
  workoutExerciseAdded('workout_exercise_added'),
  workoutExerciseRemoved('workout_exercise_removed'),
  workoutExerciseCompleted('workout_exercise_completed'),
  workoutExerciseReopened('workout_exercise_reopened'),
  workoutSetLogged('workout_set_logged'),
  workoutSetUpdated('workout_set_updated'),
  workoutSetDeleted('workout_set_deleted'),
  workoutFinished('workout_finished'),
  workoutDeleted('workout_deleted'),

  workoutRoutineCreated('workout_routine_created'),
  workoutRoutineUpdated('workout_routine_updated'),
  workoutRoutineDeleted('workout_routine_deleted'),
  workoutRoutinesReordered('workout_routines_reordered'),

  premiumPurchased('premium_purchased'),
  premiumRestored('premium_restored'),
  premiumOfferUnavailable('premium_offer_unavailable');

  const AppEvent(this.wireName);

  final String wireName;
}
