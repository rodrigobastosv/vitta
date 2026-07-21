import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_portion.dart';

class FoodLogEntry extends Equatable with FoodPortion {
  const FoodLogEntry({required this.log, required this.food});

  factory FoodLogEntry.fromMap(Map<String, dynamic> row) => FoodLogEntry(log: FoodLog.fromMap(row), food: Food.fromMap(row['foods'] as Map<String, dynamic>));

  final FoodLog log;

  @override
  final Food food;

  @override
  double get quantityGrams => log.quantityGrams;

  @override
  List<Object?> get props => [log, food];
}
