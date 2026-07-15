class CreateFoodFavoriteRequest {
  CreateFoodFavoriteRequest({required this.userId, required this.foodId});

  final String userId;
  final String foodId;

  Map<String, dynamic> toJson() => {'user_id': userId, 'food_id': foodId};
}
