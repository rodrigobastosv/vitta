enum SupabaseTable {
  foods('foods'),
  foodLogs('food_logs'),
  waterLogs('water_logs'),
  bodyWeightLogs('body_weight_logs'),
  sleepLogs('sleep_logs'),
  recipes('recipes'),
  recipeIngredients('recipe_ingredients'),
  foodFavorites('food_favorites'),
  exercises('exercises'),
  workouts('workouts'),
  workoutExercises('workout_exercises'),
  workoutSets('workout_sets'),
  routines('routines'),
  routineExercises('routine_exercises'),
  reminders('reminders'),
  progressPhotos('progress_photos'),
  subscriptions('subscriptions');

  const SupabaseTable(this.wireName);

  final String wireName;
}
