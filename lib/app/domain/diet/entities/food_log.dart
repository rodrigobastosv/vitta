import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class FoodLog extends Equatable {
  const FoodLog({
    required this.id,
    required this.foodId,
    required this.loggedDate,
    required this.mealType,
    required this.quantityGrams,
  });

  final String id;
  final String foodId;
  final DateTime loggedDate;
  final MealType mealType;
  final double quantityGrams;

  @override
  List<Object?> get props => [id, foodId, loggedDate, mealType, quantityGrams];
}
