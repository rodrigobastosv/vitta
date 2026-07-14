import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

mixin FoodPortion {
  Food get food;

  double get quantityGrams;

  double get _ratio => quantityGrams / 100;

  double get calories => food.caloriesPer100g * _ratio;

  double get protein => food.proteinPer100g * _ratio;

  double get carbs => food.carbsPer100g * _ratio;

  double get fat => food.fatPer100g * _ratio;

  double get fiber => food.fiberPer100g * _ratio;

  Map<Nutrient, double> get micronutrients => {
    for (final MapEntry(:key, :value) in food.micronutrientsPer100g.entries) key: value * _ratio,
  };
}
