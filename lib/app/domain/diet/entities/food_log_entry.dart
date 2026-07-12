import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';

class FoodLogEntry extends Equatable {
  const FoodLogEntry({required this.log, required this.food});

  factory FoodLogEntry.fromMap(Map<String, dynamic> row) =>
      FoodLogEntry(log: FoodLog.fromMap(row), food: Food.fromMap(row['foods'] as Map<String, dynamic>));

  final FoodLog log;
  final Food food;

  double get _ratio => log.quantityGrams / 100;

  double get calories => food.caloriesPer100g * _ratio;

  double get protein => food.proteinPer100g * _ratio;

  double get carbs => food.carbsPer100g * _ratio;

  double get fat => food.fatPer100g * _ratio;

  @override
  List<Object?> get props => [log, food];
}
