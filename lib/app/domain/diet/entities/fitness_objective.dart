import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

// What the user is training and eating for (issue #179), captured during
// onboarding and changeable later from the profile. It pairs each case with the
// two things that turn a body into MacroGoals - how much to eat around
// maintenance, and the DietModality whose split those calories are divided by -
// the way DietModality itself pairs a case with its ratios; the human label
// lives in l10n so the domain stays Flutter-free.
//
// The modality is *derived from* the objective rather than picked separately:
// building muscle is a high-protein diet, so choosing the goal chooses the
// split. Because the split is a real DietModality, DietModality.matching()
// recovers it from the saved grams unchanged - the goals page shows the right
// preset with no extra wiring, and nudging a macro off it reads back as custom
// exactly as before.
enum FitnessObjective {
  loseWeight(calorieFactor: 0.80, modality: .highProtein),
  maintainWeight(calorieFactor: 1, modality: .balanced),
  gainMuscle(calorieFactor: 1.12, modality: .highProtein);

  const FitnessObjective({required this.calorieFactor, required this.modality});

  static FitnessObjective? fromWireValue(String? value) {
    for (final objective in values) {
      if (objective.wireValue == value) {
        return objective;
      }
    }
    return null;
  }

  final double calorieFactor;
  final DietModality modality;

  String get wireValue => name;

  // The dietary reference intake, expressed against energy so it scales with the
  // rest of the target instead of being a flat number.
  static const _fiberGramsPer1000Calories = 14.0;

  // The maintenance figure is BasalMetabolism's (Mifflin-St Jeor x an activity
  // multiplier, issue #169), taken as an argument rather than computed here: an
  // objective is what to do *around* maintenance, and it has no business knowing
  // how a body turns into calories.
  double caloriesFor({required double maintenanceCalories}) => maintenanceCalories * calorieFactor;

  MacroGoals goalsFor({required double maintenanceCalories}) {
    final calories = caloriesFor(maintenanceCalories: maintenanceCalories);
    return MacroGoals.fromEnergySplit(
      calories: calories,
      proteinRatio: modality.proteinRatio,
      carbsRatio: modality.carbsRatio,
      fatRatio: modality.fatRatio,
      fiberGoalGrams: calories / 1000 * _fiberGramsPer1000Calories,
    );
  }
}
