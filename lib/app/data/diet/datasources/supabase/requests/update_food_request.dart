import 'package:vitta/app/domain/diet/entities/food.dart';

class UpdateFoodRequest {
  UpdateFoodRequest({required this.food});

  final Food food;

  Map<String, dynamic> toJson() => {
    'name': food.name,
    'brand': food.brand,
    'calories_per_100g': food.caloriesPer100g,
    'protein_per_100g': food.proteinPer100g,
    'carbs_per_100g': food.carbsPer100g,
    'fat_per_100g': food.fatPer100g,
    'fiber_per_100g': food.fiberPer100g,
    'micronutrients': {for (final MapEntry(:key, :value) in food.micronutrientsPer100g.entries) key.wireKey: value},
    'image_url': food.imageUrl,
  };
}
