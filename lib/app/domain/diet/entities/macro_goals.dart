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

  static const _caloriesPerGramProtein = 4.0;
  static const _caloriesPerGramCarbs = 4.0;
  static const _caloriesPerGramFat = 9.0;

  final double proteinGoalGrams;
  final double carbsGoalGrams;
  final double fatGoalGrams;
  final double fiberGoalGrams;

  double get calorieGoal =>
      proteinGoalGrams * _caloriesPerGramProtein + carbsGoalGrams * _caloriesPerGramCarbs + fatGoalGrams * _caloriesPerGramFat;

  double get calorieMin => calorieGoal * GoalAdherence.metLowerBound;
  double get calorieMax => calorieGoal * GoalAdherence.metUpperBound;

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
    return copyWith(
      proteinGoalGrams: proteinGoalGrams * factor,
      carbsGoalGrams: carbsGoalGrams * factor,
      fatGoalGrams: fatGoalGrams * factor,
    );
  }

  @override
  List<Object?> get props => [proteinGoalGrams, carbsGoalGrams, fatGoalGrams, fiberGoalGrams];
}
