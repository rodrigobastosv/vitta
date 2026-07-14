class CreateRecipeIngredientRequest {
  CreateRecipeIngredientRequest({required this.recipeId, required this.foodId, required this.quantityGrams});

  final String recipeId;
  final String foodId;
  final double quantityGrams;

  Map<String, dynamic> toJson() => {'recipe_id': recipeId, 'food_id': foodId, 'quantity_grams': quantityGrams};
}
