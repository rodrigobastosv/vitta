import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

// A diet modality is a preset protein/carbs/fat energy split (fractions of total
// calories) that drives the macro goals - "high protein", "low fat", etc. (issue
// #122). It pairs each case with its split the way MealType pairs a case with its
// wire value; the human label lives in l10n (see dietModalityLabel in the
// presentation layer), so the domain stays Flutter-free.
//
// A modality is never stored: applyTo turns a split into grams at a calorie target,
// and matching recovers the modality from the grams, so tweaking a macro slider off
// a preset naturally reads back as no match (a custom split) with nothing to persist.
enum DietModality {
  balanced(proteinRatio: 0.30, carbsRatio: 0.40, fatRatio: 0.30),
  highProtein(proteinRatio: 0.40, carbsRatio: 0.30, fatRatio: 0.30),
  lowFat(proteinRatio: 0.30, carbsRatio: 0.55, fatRatio: 0.15),
  lowCarb(proteinRatio: 0.40, carbsRatio: 0.20, fatRatio: 0.40),
  keto(proteinRatio: 0.30, carbsRatio: 0.05, fatRatio: 0.65);

  const DietModality({required this.proteinRatio, required this.carbsRatio, required this.fatRatio});

  final double proteinRatio;
  final double carbsRatio;
  final double fatRatio;

  // How close a goal's actual split has to sit to a modality's to still count as
  // that modality (3 percentage points), so integer-gram slider drift doesn't drop
  // a preset to "custom".
  static const _matchTolerance = 0.03;

  // A calorie base to build the split on when the current goals carry no energy at
  // all (every macro zeroed) - there's no total to keep, so pick a sensible target.
  static const _fallbackCalories = 2000.0;

  // The same calorie target as `goals`, re-split by this modality's ratios. Fiber
  // is preserved - it's not part of the energy split.
  MacroGoals applyTo(MacroGoals goals) => MacroGoals.fromEnergySplit(
    calories: goals.calorieGoal > 0 ? goals.calorieGoal : _fallbackCalories,
    proteinRatio: proteinRatio,
    carbsRatio: carbsRatio,
    fatRatio: fatRatio,
    fiberGoalGrams: goals.fiberGoalGrams,
  );

  bool matches(MacroGoals goals) =>
      goals.calorieGoal > 0 &&
      (goals.proteinCalorieRatio - proteinRatio).abs() <= _matchTolerance &&
      (goals.carbsCalorieRatio - carbsRatio).abs() <= _matchTolerance &&
      (goals.fatCalorieRatio - fatRatio).abs() <= _matchTolerance;

  // The modality whose split matches these goals, or null when the split is custom.
  static DietModality? matching(MacroGoals goals) {
    for (final modality in values) {
      if (modality.matches(goals)) {
        return modality;
      }
    }
    return null;
  }
}
