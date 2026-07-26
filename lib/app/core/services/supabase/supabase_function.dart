enum SupabaseFunction {
  scanNutritionLabel('scan-nutrition-label'),
  scanMeal('scan-meal'),
  suggestMeals('suggest-meals'),
  deleteAccount('delete-account');

  const SupabaseFunction(this.wireName);

  final String wireName;
}
