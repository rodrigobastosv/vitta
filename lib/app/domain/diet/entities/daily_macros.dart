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
    if (goals.calorieGoal <= 0) {
      return .met;
    }
    return GoalAdherence.forRatio(totalCalories / goals.calorieGoal);
  }

  @override
  List<Object?> get props => [entries];
}
