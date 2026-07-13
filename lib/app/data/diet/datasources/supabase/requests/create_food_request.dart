import 'package:vitta/app/domain/diet/entities/food.dart';

class CreateFoodRequest {
  CreateFoodRequest({required this.food, required this.userId});

  final Food food;
  final String userId;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': food.name,
    'brand': food.brand,
    'barcode': food.barcode,
    'source': food.source.wireValue,
    'calories_per_100g': food.caloriesPer100g,
    'protein_per_100g': food.proteinPer100g,
    'carbs_per_100g': food.carbsPer100g,
    'fat_per_100g': food.fatPer100g,
    'fiber_per_100g': food.fiberPer100g,
    'micronutrients': {for (final MapEntry(:key, :value) in food.micronutrientsPer100g.entries) key.wireKey: value},
    'image_url': food.imageUrl,
  };
}
