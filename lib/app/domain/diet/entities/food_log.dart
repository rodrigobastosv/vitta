import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class FoodLog extends Equatable {
  const FoodLog({
    required this.id,
    required this.foodId,
    required this.loggedDate,
    required this.mealType,
    required this.quantityGrams,
    this.quantityUnits,
    this.quantityMl,
  });

  factory FoodLog.fromMap(Map<String, dynamic> row) => FoodLog(
    id: row['id'] as String,
    foodId: row['food_id'] as String,
    loggedDate: DateTime.parse(row['logged_date'] as String),
    mealType: MealType.fromWireValue(row['meal_type'] as String),
    quantityGrams: (row['quantity_grams'] as num).toDouble(),
    quantityUnits: (row['quantity_units'] as num?)?.toDouble(),
    quantityMl: (row['quantity_ml'] as num?)?.toDouble(),
  );

  final String id;
  final String foodId;
  final DateTime loggedDate;
  final MealType mealType;
  final double quantityGrams;

  final double? quantityUnits;

  final double? quantityMl;

  bool get isLoggedInUnits => quantityUnits != null;

  bool get isLoggedInMilliliters => quantityMl != null;

  @override
  List<Object?> get props => [id, foodId, loggedDate, mealType, quantityGrams, quantityUnits, quantityMl];
}
