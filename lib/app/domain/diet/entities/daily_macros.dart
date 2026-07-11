import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';

class DailyMacros extends Equatable {
  const DailyMacros({required this.entries});

  final List<FoodLogEntry> entries;

  double get totalCalories => entries.fold(0, (sum, entry) => sum + entry.calories);

  double get totalProtein => entries.fold(0, (sum, entry) => sum + entry.protein);

  double get totalCarbs => entries.fold(0, (sum, entry) => sum + entry.carbs);

  double get totalFat => entries.fold(0, (sum, entry) => sum + entry.fat);

  @override
  List<Object?> get props => [entries];
}
