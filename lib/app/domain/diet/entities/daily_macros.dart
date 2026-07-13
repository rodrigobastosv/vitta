import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/goal_adherence.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';
import 'package:vitta/app/domain/diet/entities/meal_section.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class DailyMacros extends Equatable with MacroTotals {
  const DailyMacros({required this.entries});

  @override
  final List<FoodLogEntry> entries;

  List<MealSection> get meals {
    final sections = <MealSection>[];
    for (final mealType in MealType.values) {
      final mealEntries = entries.where((entry) => entry.log.mealType == mealType).toList();
      if (mealEntries.isNotEmpty) {
        sections.add(MealSection(mealType: mealType, entries: mealEntries));
      }
    }
    return sections;
  }

  GoalAdherence adherenceTo(MacroGoals goals) {
    final ratios = [
      if (goals.calorieGoal > 0) totalCalories / goals.calorieGoal,
      if (goals.proteinGoalGrams > 0) totalProtein / goals.proteinGoalGrams,
      if (goals.carbsGoalGrams > 0) totalCarbs / goals.carbsGoalGrams,
      if (goals.fatGoalGrams > 0) totalFat / goals.fatGoalGrams,
      if (goals.fiberGoalGrams > 0) totalFiber / goals.fiberGoalGrams,
    ];
    return ratios.map(GoalAdherence.forRatio).fold(.met, (worst, status) => worst.combineWorst(status));
  }

  @override
  List<Object?> get props => [entries];
}
