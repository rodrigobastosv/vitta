import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class MealSection extends Equatable with MacroTotals {
  const MealSection({required this.mealType, required this.entries});

  final MealType mealType;

  @override
  final List<FoodLogEntry> entries;

  @override
  List<Object?> get props => [mealType, entries];
}
