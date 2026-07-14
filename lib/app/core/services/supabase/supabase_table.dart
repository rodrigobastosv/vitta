enum SupabaseTable {
  foods('foods'),
  foodLogs('food_logs'),
  waterLogs('water_logs'),
  sleepLogs('sleep_logs'),
  recipes('recipes'),
  recipeIngredients('recipe_ingredients');

  const SupabaseTable(this.wireName);

  final String wireName;
}
