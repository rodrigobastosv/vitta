import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/general/food_category_visual.dart';

// The domain-aware wrapper over the design system's VTFoodImage: given a Food it
// renders the photo when there is one, and otherwise a category icon tinted by
// the food's group (issue #206) instead of the neutral fork/knife. Keeps the
// FoodCategory -> icon/colour mapping out of the design system, which stays
// primitive, and off the eight call sites, which just hand it a Food.
class FoodImage extends StatelessWidget {
  const FoodImage({required this.food, this.size = 48, super.key});

  final Food food;
  final double size;

  @override
  Widget build(BuildContext context) {
    final category = food.category;
    return VTFoodImage(
      imageUrl: food.imageUrl,
      placeholderIcon: category == null ? Icons.restaurant_outlined : foodCategoryIcon(category),
      placeholderTint: category == null ? null : foodCategoryColor(category),
      size: size,
    );
  }
}
