import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/diet/entities/food_category.dart';

// Maps a food group to the icon + accent tint its placeholder avatar wears (see
// issue #206), the `mealTypeIcon`/`mealTypeColor` pattern that keeps the domain
// enum Flutter-free. Colours are grouped by macro character - plants green,
// grains/sweets amber, proteins coral, fats/drinks blue - so the list reads as a
// coherent palette rather than ten unrelated hues. Material has no literal
// fruit/vegetable glyph, so these are the closest recognisable stand-ins.
IconData foodCategoryIcon(FoodCategory category) => switch (category) {
  FoodCategory.fruit => Icons.spa_outlined,
  FoodCategory.vegetable => Icons.eco_outlined,
  FoodCategory.grain => Icons.bakery_dining_outlined,
  FoodCategory.protein => Icons.set_meal_outlined,
  FoodCategory.dairyEgg => Icons.egg_outlined,
  FoodCategory.legumeNut => Icons.grain_outlined,
  FoodCategory.fatOil => Icons.water_drop_outlined,
  FoodCategory.beverage => Icons.local_cafe_outlined,
  FoodCategory.sweet => Icons.cake_outlined,
  FoodCategory.condiment => Icons.soup_kitchen_outlined,
};

Color foodCategoryColor(FoodCategory category) => switch (category) {
  FoodCategory.fruit => VTColors.coral,
  FoodCategory.vegetable => VTColors.green,
  FoodCategory.grain => VTColors.macroCarbs,
  FoodCategory.protein => VTColors.macroProtein,
  FoodCategory.dairyEgg => VTColors.macroCarbs,
  FoodCategory.legumeNut => VTColors.macroFiber,
  FoodCategory.fatOil => VTColors.macroFat,
  FoodCategory.beverage => VTColors.water,
  FoodCategory.sweet => VTColors.sleep,
  FoodCategory.condiment => VTColors.macroFiber,
};
