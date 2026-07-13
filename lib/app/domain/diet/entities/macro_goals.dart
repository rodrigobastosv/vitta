import 'package:equatable/equatable.dart';

class MacroGoals extends Equatable {
  const MacroGoals({
    required this.calorieGoal,
    required this.proteinGoalGrams,
    required this.carbsGoalGrams,
    required this.fatGoalGrams,
    required this.fiberGoalGrams,
  });

  static const defaultGoals = MacroGoals(
    calorieGoal: 2000,
    proteinGoalGrams: 150,
    carbsGoalGrams: 250,
    fatGoalGrams: 65,
    fiberGoalGrams: 30,
  );

  final double calorieGoal;
  final double proteinGoalGrams;
  final double carbsGoalGrams;
  final double fatGoalGrams;
  final double fiberGoalGrams;

  @override
  List<Object?> get props => [calorieGoal, proteinGoalGrams, carbsGoalGrams, fatGoalGrams, fiberGoalGrams];
}
