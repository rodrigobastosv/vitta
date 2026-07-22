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

  // Mifflin-St Jeor without the sex and age terms the app never asks for: the
  // age coefficient is evaluated at _referenceAgeYears and the sex constant is
  // the midpoint of its male (+5) and female (-161) values. The app trades that
  // accuracy for two questions instead of four - the result is a starting
  // suggestion the user can move with a slider, not a prescription.
  static const _weightCoefficient = 10.0;
  static const _heightCoefficient = 6.25;
  static const _referenceAgeYears = 30.0;
  static const _ageCoefficient = 5.0;
  static const _neutralSexConstant = -78.0;

  // Lightly active, the safest assumption for someone who has just installed a
  // tracker and told us nothing about how they move.
  static const _activityFactor = 1.375;

  // The dietary reference intake, expressed against energy so it scales with the
  // rest of the target instead of being a flat number.
  static const _fiberGramsPer1000Calories = 14.0;

  static double basalCalories({required double weightKg, required double heightCm}) =>
      _weightCoefficient * weightKg + _heightCoefficient * heightCm - _ageCoefficient * _referenceAgeYears + _neutralSexConstant;

  static double maintenanceCalories({required double weightKg, required double heightCm}) =>
      basalCalories(weightKg: weightKg, heightCm: heightCm) * _activityFactor;

  double caloriesFor({required double weightKg, required double heightCm}) =>
      maintenanceCalories(weightKg: weightKg, heightCm: heightCm) * calorieFactor;

  MacroGoals goalsFor({required double weightKg, required double heightCm}) {
    final calories = caloriesFor(weightKg: weightKg, heightCm: heightCm);
    return MacroGoals.fromEnergySplit(
      calories: calories,
      proteinRatio: modality.proteinRatio,
      carbsRatio: modality.carbsRatio,
      fatRatio: modality.fatRatio,
      fiberGoalGrams: calories / 1000 * _fiberGramsPer1000Calories,
    );
  }
}
