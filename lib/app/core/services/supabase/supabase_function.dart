enum SupabaseFunction {
  scanNutritionLabel('scan-nutrition-label'),
  deleteAccount('delete-account');

  const SupabaseFunction(this.wireName);

  final String wireName;
}
