import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

// What the user is training and eating for (issue #179), captured once during
// onboarding alongside their weight and height. It pairs each case with the two
// numbers that turn a body into a calorie target - how much to eat around
// maintenance, and how much protein per kilogram - the way DietModality pairs a
// case with its energy split; the human label lives in l10n so the domain stays
// Flutter-free.
//
// An objective is never stored. It exists to *derive* MacroGoals, which are what
// gets persisted and what the user then owns and edits - the same call the
// calorie goal makes by being a getter over the macro grams rather than a column.
enum FitnessObjective {
  loseWeight(calorieFactor: 0.80, proteinGramsPerKilogram: 2, fatCalorieRatio: 0.25),
  maintainWeight(calorieFactor: 1, proteinGramsPerKilogram: 1.6, fatCalorieRatio: 0.30),
  gainMuscle(calorieFactor: 1.12, proteinGramsPerKilogram: 1.8, fatCalorieRatio: 0.25);

  const FitnessObjective({required this.calorieFactor, required this.proteinGramsPerKilogram, required this.fatCalorieRatio});

  final double calorieFactor;
  final double proteinGramsPerKilogram;
  final double fatCalorieRatio;

  // Mifflin-St Jeor without the sex and age terms the app never asks for: the
  // age coefficient is evaluated at _referenceAgeYears and the sex constant is
  // the midpoint of its male (+5) and female (-161) values. Onboarding trades
  // that accuracy for two questions instead of four - the result is a starting
  // suggestion the user can move with a slider, not a prescription.
  static const _weightCoefficient = 10.0;
  static const _heightCoefficient = 6.25;
  static const _referenceAgeYears = 30.0;
  static const _ageCoefficient = 5.0;
  static const _neutralSexConstant = -78.0;

  // Lightly active, the safest assumption for someone who has just installed a
  // tracker and told us nothing about how they move.
  static const _activityFactor = 1.375;

  static const _caloriesPerGramProtein = 4.0;
  static const _caloriesPerGramCarbs = 4.0;
  static const _caloriesPerGramFat = 9.0;

  // The dietary reference intake, expressed against energy so it scales with the
  // rest of the target instead of being a flat number.
  static const _fiberGramsPer1000Calories = 14.0;

  static double basalCalories({required double weightKg, required double heightCm}) =>
      _weightCoefficient * weightKg + _heightCoefficient * heightCm - _ageCoefficient * _referenceAgeYears + _neutralSexConstant;

  static double maintenanceCalories({required double weightKg, required double heightCm}) =>
      basalCalories(weightKg: weightKg, heightCm: heightCm) * _activityFactor;

  double caloriesFor({required double weightKg, required double heightCm}) =>
      maintenanceCalories(weightKg: weightKg, heightCm: heightCm) * calorieFactor;

  // Protein is set per kilogram of body weight rather than as a share of calories
  // - it is what the body needs, not what the plate happens to total - so a cut
  // keeps its protein while its calories come down. Fat takes a fixed share of
  // what is left and carbs absorb the remainder, floored at zero so an extreme
  // body never produces a negative goal.
  MacroGoals goalsFor({required double weightKg, required double heightCm}) {
    final calories = caloriesFor(weightKg: weightKg, heightCm: heightCm);
    final proteinGrams = weightKg * proteinGramsPerKilogram;
    final fatGrams = calories * fatCalorieRatio / _caloriesPerGramFat;
    final carbsCalories = calories - proteinGrams * _caloriesPerGramProtein - fatGrams * _caloriesPerGramFat;
    return MacroGoals(
      proteinGoalGrams: proteinGrams,
      carbsGoalGrams: carbsCalories > 0 ? carbsCalories / _caloriesPerGramCarbs : 0,
      fatGoalGrams: fatGrams,
      fiberGoalGrams: calories / 1000 * _fiberGramsPer1000Calories,
    );
  }
}
