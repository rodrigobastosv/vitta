import 'package:equatable/equatable.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';

class MacroGoals extends Equatable {
  const MacroGoals({required this.proteinGoalGrams, required this.carbsGoalGrams, required this.fatGoalGrams, required this.fiberGoalGrams});

  // Grams that put `calories` behind the given protein/carbs/fat energy split
  // (fractions of total calories, e.g. 0.30/0.40/0.30). The kcal-per-gram
  // conversion stays here so a diet modality never has to know it. Fiber isn't an
  // energy macro, so it's carried through untouched rather than derived from the split.
  factory MacroGoals.fromEnergySplit({
    required double calories,
    required double proteinRatio,
    required double carbsRatio,
    required double fatRatio,
    required double fiberGoalGrams,
  }) => MacroGoals(
    proteinGoalGrams: calories * proteinRatio / _caloriesPerGramProtein,
    carbsGoalGrams: calories * carbsRatio / _caloriesPerGramCarbs,
    fatGoalGrams: calories * fatRatio / _caloriesPerGramFat,
    fiberGoalGrams: fiberGoalGrams,
  );

  static const defaultGoals = MacroGoals(proteinGoalGrams: 150, carbsGoalGrams: 250, fatGoalGrams: 65, fiberGoalGrams: 30);

  static const _caloriesPerGramProtein = 4.0;
  static const _caloriesPerGramCarbs = 4.0;
  static const _caloriesPerGramFat = 9.0;

  final double proteinGoalGrams;
  final double carbsGoalGrams;
  final double fatGoalGrams;
  final double fiberGoalGrams;

  double get calorieGoal => proteinGoalGrams * _caloriesPerGramProtein + carbsGoalGrams * _caloriesPerGramCarbs + fatGoalGrams * _caloriesPerGramFat;

  double get calorieMin => calorieGoal * GoalAdherence.metLowerBound;
  double get calorieMax => calorieGoal * GoalAdherence.metUpperBound;

  // Each energy macro's share of the calorie goal, so a diet modality can be
  // matched back from the grams (0 when there's no energy to divide). These are
  // the inverse of fromEnergySplit and the reason a modality needs no stored field.
  double get proteinCalorieRatio => calorieGoal > 0 ? proteinGoalGrams * _caloriesPerGramProtein / calorieGoal : 0;
  double get carbsCalorieRatio => calorieGoal > 0 ? carbsGoalGrams * _caloriesPerGramCarbs / calorieGoal : 0;
  double get fatCalorieRatio => calorieGoal > 0 ? fatGoalGrams * _caloriesPerGramFat / calorieGoal : 0;

  MacroGoals copyWith({double? proteinGoalGrams, double? carbsGoalGrams, double? fatGoalGrams, double? fiberGoalGrams}) => MacroGoals(
    proteinGoalGrams: proteinGoalGrams ?? this.proteinGoalGrams,
    carbsGoalGrams: carbsGoalGrams ?? this.carbsGoalGrams,
    fatGoalGrams: fatGoalGrams ?? this.fatGoalGrams,
    fiberGoalGrams: fiberGoalGrams ?? this.fiberGoalGrams,
  );

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
    return copyWith(proteinGoalGrams: proteinGoalGrams * factor, carbsGoalGrams: carbsGoalGrams * factor, fatGoalGrams: fatGoalGrams * factor);
  }

  @override
  List<Object?> get props => [proteinGoalGrams, carbsGoalGrams, fatGoalGrams, fiberGoalGrams];
}
