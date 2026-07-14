import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_portion.dart';

class RecipeIngredient extends Equatable with FoodPortion {
  const RecipeIngredient({required this.food, required this.quantityGrams, this.id});

  factory RecipeIngredient.fromMap(Map<String, dynamic> row) => RecipeIngredient(
    id: row['id'] as String,
    food: Food.fromMap(row['foods'] as Map<String, dynamic>),
    quantityGrams: (row['quantity_grams'] as num).toDouble(),
  );

  final String? id;

  @override
  final Food food;

  @override
  final double quantityGrams;

  @override
  List<Object?> get props => [id, food, quantityGrams];
}
