import 'package:equatable/equatable.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';

class MacroGoals extends Equatable {
  const MacroGoals({
    required this.proteinGoalGrams,
    required this.carbsGoalGrams,
    required this.fatGoalGrams,
    required this.fiberGoalGrams,
  });

  static const defaultGoals = MacroGoals(proteinGoalGrams: 150, carbsGoalGrams: 250, fatGoalGrams: 65, fiberGoalGrams: 30);

  // Atwater energy factors (kcal per gram). Fiber isn't counted: it's part of
  // carbs, so adding it would double-count. Same 4/4/9 the energy-split card uses.
  static const _caloriesPerGramProtein = 4.0;
  static const _caloriesPerGramCarbs = 4.0;
  static const _caloriesPerGramFat = 9.0;

  final double proteinGoalGrams;
  final double carbsGoalGrams;
  final double fatGoalGrams;
  final double fiberGoalGrams;

  /// Calories are the energy of the macro goals, not a separate figure the user
  /// sets (issue #116) - editing a macro moves the calorie target with it, and
  /// the two can never disagree.
  double get calorieGoal =>
      proteinGoalGrams * _caloriesPerGramProtein + carbsGoalGrams * _caloriesPerGramCarbs + fatGoalGrams * _caloriesPerGramFat;

  /// The "on target" band around the calorie goal - the same green range
  /// GoalAdherence paints the calendar and the calorie ring with.
  double get calorieMin => calorieGoal * GoalAdherence.metLowerBound;
  double get calorieMax => calorieGoal * GoalAdherence.metUpperBound;

  MacroGoals copyWith({double? proteinGoalGrams, double? carbsGoalGrams, double? fatGoalGrams, double? fiberGoalGrams}) => MacroGoals(
    proteinGoalGrams: proteinGoalGrams ?? this.proteinGoalGrams,
    carbsGoalGrams: carbsGoalGrams ?? this.carbsGoalGrams,
    fatGoalGrams: fatGoalGrams ?? this.fatGoalGrams,
    fiberGoalGrams: fiberGoalGrams ?? this.fiberGoalGrams,
  );

  /// Rescales the energy macros so the calorie goal becomes [targetCalories],
  /// keeping their proportions - what dragging the calorie slider does (issue
  /// #116). Fiber is left alone since it carries no energy. When the current
  /// macros are all zero there's no ratio to preserve, so it falls back to a
  /// balanced 30/40/30 split by energy, which keeps the slider usable.
  MacroGoals withScaledCalories(double targetCalories) {
    final target = targetCalories < 0 ? 0.0 : targetCalories;
    if (calorieGoal <= 0) {
      return copyWith(
        proteinGoalGrams: target * 0.30 / _caloriesPerGramProtein,
        carbsGoalGrams: target * 0.40 / _caloriesPerGramCarbs,
        fatGoalGrams: target * 0.30 / _caloriesPerGramFat,
      );
    }
    final factor = target / calorieGoal;
    return copyWith(
      proteinGoalGrams: proteinGoalGrams * factor,
      carbsGoalGrams: carbsGoalGrams * factor,
      fatGoalGrams: fatGoalGrams * factor,
    );
  }

  @override
  List<Object?> get props => [proteinGoalGrams, carbsGoalGrams, fatGoalGrams, fiberGoalGrams];
}
