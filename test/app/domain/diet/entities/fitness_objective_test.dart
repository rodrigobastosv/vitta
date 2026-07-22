import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';

void main() {
  const weightKg = 70.0;
  const heightCm = 170.0;

  test('maintenance sits between the cut and the bulk', () {
    final losing = FitnessObjective.loseWeight.caloriesFor(weightKg: weightKg, heightCm: heightCm);
    final maintaining = FitnessObjective.maintainWeight.caloriesFor(weightKg: weightKg, heightCm: heightCm);
    final gaining = FitnessObjective.gainMuscle.caloriesFor(weightKg: weightKg, heightCm: heightCm);

    expect(losing, lessThan(maintaining));
    expect(gaining, greaterThan(maintaining));
  });

  test('maintaining suggests exactly the maintenance estimate', () {
    expect(
      FitnessObjective.maintainWeight.caloriesFor(weightKg: weightKg, heightCm: heightCm),
      closeTo(FitnessObjective.maintenanceCalories(weightKg: weightKg, heightCm: heightCm), 0.001),
    );
  });

  test('height moves the target, so it is a real input and not decoration', () {
    final shorter = FitnessObjective.maintainWeight.caloriesFor(weightKg: weightKg, heightCm: 160);
    final taller = FitnessObjective.maintainWeight.caloriesFor(weightKg: weightKg, heightCm: 190);

    expect(taller, greaterThan(shorter));
  });

  test('the suggested macros total the suggested calories', () {
    for (final objective in FitnessObjective.values) {
      final goals = objective.goalsFor(weightKg: weightKg, heightCm: heightCm);

      expect(goals.calorieGoal, closeTo(objective.caloriesFor(weightKg: weightKg, heightCm: heightCm), 0.001), reason: objective.name);
    }
  });

  test('protein is set per kilogram of body weight, not as a share of the plate', () {
    final goals = FitnessObjective.loseWeight.goalsFor(weightKg: weightKg, heightCm: heightCm);

    expect(goals.proteinGoalGrams, closeTo(weightKg * FitnessObjective.loseWeight.proteinGramsPerKilogram, 0.001));
  });

  test('a body whose protein alone would exceed the target never yields negative carbs', () {
    final goals = FitnessObjective.loseWeight.goalsFor(weightKg: 300, heightCm: 1);

    expect(goals.carbsGoalGrams, 0);
  });
}
