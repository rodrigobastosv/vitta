import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/services/analytics/analytics_parameters.dart';
import 'package:vitta/app/core/services/logging/app_event.dart';

void main() {
  // The wire names are the analytics contract: GA4 keys a funnel on the string,
  // so renaming one starts a new event and orphans every figure recorded under
  // the old name. This list is deliberately a literal rather than derived from
  // the enum - a test that reads both sides off the same source would pass while
  // the rename it exists to catch went through.
  const wireNames = {
    AppEvent.signIn: 'sign_in',
    AppEvent.signUp: 'sign_up',
    AppEvent.signOut: 'sign_out',
    AppEvent.accountDeleted: 'account_deleted',
    AppEvent.profileUpdated: 'profile_updated',
    AppEvent.onboardingCompleted: 'onboarding_completed',
    AppEvent.onboardingGoalsSet: 'onboarding_goals_set',
    AppEvent.onboardingWeightLogged: 'onboarding_weight_logged',
    AppEvent.objectiveChanged: 'objective_changed',
    AppEvent.themeChanged: 'theme_changed',
    AppEvent.localeChanged: 'locale_changed',
    AppEvent.unitSystemChanged: 'unit_system_changed',
    AppEvent.foodLogged: 'food_logged',
    AppEvent.foodLogUpdated: 'food_log_updated',
    AppEvent.foodLogDeleted: 'food_log_deleted',
    AppEvent.foodFavorited: 'food_favorited',
    AppEvent.foodUnfavorited: 'food_unfavorited',
    AppEvent.mealLoggedFromScan: 'meal_logged_from_scan',
    AppEvent.mealsCopied: 'meals_copied',
    AppEvent.macroGoalsSaved: 'macro_goals_saved',
    AppEvent.recipeCreated: 'recipe_created',
    AppEvent.recipeUpdated: 'recipe_updated',
    AppEvent.recipeDeleted: 'recipe_deleted',
    AppEvent.waterLogged: 'water_logged',
    AppEvent.waterLogDeleted: 'water_log_deleted',
    AppEvent.waterGoalChanged: 'water_goal_changed',
    AppEvent.sleepLogged: 'sleep_logged',
    AppEvent.sleepLogDeleted: 'sleep_log_deleted',
    AppEvent.sleepImportedFromHealth: 'sleep_imported_from_health',
    AppEvent.bodyWeightLogged: 'body_weight_logged',
    AppEvent.bodyWeightLogDeleted: 'body_weight_log_deleted',
    AppEvent.progressPhotoAdded: 'progress_photo_added',
    AppEvent.progressPhotoDeleted: 'progress_photo_deleted',
    AppEvent.reminderCreated: 'reminder_created',
    AppEvent.reminderCompleted: 'reminder_completed',
    AppEvent.reminderDeleted: 'reminder_deleted',
    AppEvent.workoutStartedFromRoutine: 'workout_started_from_routine',
    AppEvent.workoutExerciseAdded: 'workout_exercise_added',
    AppEvent.workoutExerciseRemoved: 'workout_exercise_removed',
    AppEvent.workoutExerciseCompleted: 'workout_exercise_completed',
    AppEvent.workoutExerciseReopened: 'workout_exercise_reopened',
    AppEvent.workoutSetLogged: 'workout_set_logged',
    AppEvent.workoutSetUpdated: 'workout_set_updated',
    AppEvent.workoutSetDeleted: 'workout_set_deleted',
    AppEvent.workoutFinished: 'workout_finished',
    AppEvent.workoutDeleted: 'workout_deleted',
    AppEvent.workoutRoutineCreated: 'workout_routine_created',
    AppEvent.workoutRoutineUpdated: 'workout_routine_updated',
    AppEvent.workoutRoutineDeleted: 'workout_routine_deleted',
    AppEvent.workoutRoutinesReordered: 'workout_routines_reordered',
    AppEvent.premiumPurchased: 'premium_purchased',
    AppEvent.premiumRestored: 'premium_restored',
    AppEvent.premiumOfferUnavailable: 'premium_offer_unavailable',
  };

  test('every event keeps the wire name analytics already reports it under', () {
    for (final event in AppEvent.values) {
      expect(event.wireName, wireNames[event], reason: 'renaming ${event.name} would orphan its GA4 history');
    }
  });

  test('the catalog covers every case, so a new event cannot ship unpinned', () {
    expect(wireNames.keys, containsAll(AppEvent.values));
    expect(wireNames.length, AppEvent.values.length);
  });

  test('wire names are unique', () {
    expect(AppEvent.values.map((event) => event.wireName).toSet(), hasLength(AppEvent.values.length));
  });

  // GA4 drops a too-long, reserved-prefixed or oddly-spelled event name silently,
  // and AnalyticsParameters folds one into something legal - which would report a
  // different name than the one written here. Asserting the fold is the identity
  // is what makes the catalog itself the reported name.
  test('every wire name is already GA4-legal, so sanitizing never rewrites it', () {
    for (final event in AppEvent.values) {
      expect(AnalyticsParameters.eventName(event.wireName), event.wireName);
      expect(event.wireName, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
    }
  });
}
