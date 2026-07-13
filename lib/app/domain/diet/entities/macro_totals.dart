import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

mixin MacroTotals {
  List<FoodLogEntry> get entries;

  double get totalCalories => entries.fold(0, (sum, entry) => sum + entry.calories);

  double get totalProtein => entries.fold(0, (sum, entry) => sum + entry.protein);

  double get totalCarbs => entries.fold(0, (sum, entry) => sum + entry.carbs);

  double get totalFat => entries.fold(0, (sum, entry) => sum + entry.fat);

  double get totalFiber => entries.fold(0, (sum, entry) => sum + entry.fiber);

  Map<Nutrient, double> get micronutrientTotals {
    final totals = <Nutrient, double>{};
    for (final entry in entries) {
      entry.micronutrients.forEach((nutrient, amount) {
        totals[nutrient] = (totals[nutrient] ?? 0) + amount;
      });
    }
    return totals;
  }
}
