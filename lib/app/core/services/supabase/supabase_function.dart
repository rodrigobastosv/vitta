enum SupabaseFunction {
  scanNutritionLabel('scan-nutrition-label'),
  scanMeal('scan-meal'),
  deleteAccount('delete-account');

  const SupabaseFunction(this.wireName);

  final String wireName;
}
