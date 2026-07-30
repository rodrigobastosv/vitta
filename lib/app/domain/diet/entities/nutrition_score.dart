import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/macro_nutrient.dart';
import 'package:vitta/app/domain/diet/entities/macro_totals.dart';
import 'package:vitta/app/domain/diet/entities/nutrient_score.dart';
import 'package:vitta/app/domain/diet/entities/nutrition_grade.dart';

// How well a day landed on all five of its targets, out of 100. Derived from the
// macros and the goals that already exist, never stored - the same call
// MacroGoals.calorieGoal and MacroGap make.
//
// This is deliberately a *different artifact* from GoalAdherence, which stays
// calories-only: the calendar dot and the calorie ring answer "did the calories
// land", and a fold across every macro was tried and dropped for that job. A
// score is read on its own screen, where the broader question is the point.
class NutritionScore extends Equatable {
  const NutritionScore({required this.components});

  // Takes MacroTotals rather than DailyMacros, so a single meal can be scored on
  // the same code a day is - the generalisation MacroTotals already made for
  // recipes and food portions.
  factory NutritionScore.of({required MacroTotals consumed, required MacroGoals goals}) => NutritionScore(
    components: [
      for (final nutrient in MacroNutrient.values)
        NutrientScore(nutrient: nutrient, consumed: nutrient.consumedIn(consumed), goal: nutrient.goalIn(goals)),
    ],
  );

  final List<NutrientScore> components;

  List<NutrientScore> get scoredComponents => components.where((component) => component.isScorable).toList();

  bool get isScorable => scoredComponents.isNotEmpty;

  // Renormalised over whichever nutrients actually carry a goal, so dropping one
  // redistributes its weight rather than capping the day below 100.
  int get points {
    final scored = scoredComponents;
    final totalWeight = scored.fold<double>(0, (sum, component) => sum + component.nutrient.scoreWeight);
    if (totalWeight <= 0) {
      return 0;
    }
    final earned = scored.fold<double>(0, (sum, component) => sum + component.fraction * component.nutrient.scoreWeight);
    return (earned / totalWeight * 100).round();
  }

  NutritionGrade get grade => NutritionGrade.forPoints(points);

  NutrientScore componentFor(MacroNutrient nutrient) => components.firstWhere((component) => component.nutrient == nutrient);

  @override
  List<Object?> get props => [components];
}
