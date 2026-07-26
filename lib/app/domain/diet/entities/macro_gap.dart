import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

// What is left of the day's goals once what has already been logged is taken
// off. Derived from the two things that already exist, never stored - the same
// call MacroGoals.calorieGoal makes - so it can never disagree with the day it
// was computed from.
class MacroGap extends Equatable {
  const MacroGap({required this.calories, required this.protein, required this.carbs, required this.fat, required this.fiber});

  // A negative figure is kept rather than clamped to zero: "400 kcal over" is
  // something a suggestion has to be told about, and zero would read as a day
  // that lands exactly on its goal.
  factory MacroGap.between({required DailyMacros consumed, required MacroGoals goals}) => MacroGap(
    calories: goals.calorieGoal - consumed.totalCalories,
    protein: goals.proteinGoalGrams - consumed.totalProtein,
    carbs: goals.carbsGoalGrams - consumed.totalCarbs,
    fat: goals.fatGoalGrams - consumed.totalFat,
    fiber: goals.fiberGoalGrams - consumed.totalFiber,
  );

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  bool get isMet => calories <= 0;

  @override
  List<Object?> get props => [calories, protein, carbs, fat, fiber];
}
