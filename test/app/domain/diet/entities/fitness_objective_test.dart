import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
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

  test('building muscle is a high-protein diet, so the objective carries the modality', () {
    expect(FitnessObjective.gainMuscle.modality, DietModality.highProtein);
    expect(FitnessObjective.maintainWeight.modality, DietModality.balanced);
  });

  test('the saved grams read back as the objective own modality, so the goals page needs no wiring', () {
    for (final objective in FitnessObjective.values) {
      final goals = objective.goalsFor(weightKg: weightKg, heightCm: heightCm);

      expect(DietModality.matching(goals), objective.modality, reason: objective.name);
    }
  });

  test('an objective survives a round trip through its wire value', () {
    for (final objective in FitnessObjective.values) {
      expect(FitnessObjective.fromWireValue(objective.wireValue), objective);
    }
    expect(FitnessObjective.fromWireValue(null), isNull);
    expect(FitnessObjective.fromWireValue('bulk'), isNull);
  });
}
