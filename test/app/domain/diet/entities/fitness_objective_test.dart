import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';

void main() {
  const maintenanceCalories = 2400.0;

  test('maintenance sits between the cut and the bulk', () {
    final losing = FitnessObjective.loseWeight.caloriesFor(maintenanceCalories: maintenanceCalories);
    final maintaining = FitnessObjective.maintainWeight.caloriesFor(maintenanceCalories: maintenanceCalories);
    final gaining = FitnessObjective.gainMuscle.caloriesFor(maintenanceCalories: maintenanceCalories);

    expect(losing, lessThan(maintaining));
    expect(gaining, greaterThan(maintaining));
  });

  test('maintaining suggests exactly the maintenance estimate it was handed', () {
    expect(FitnessObjective.maintainWeight.caloriesFor(maintenanceCalories: maintenanceCalories), closeTo(maintenanceCalories, 0.001));
  });

  test('a bigger maintenance moves every target, so the metabolic estimate is a real input', () {
    for (final objective in FitnessObjective.values) {
      expect(
        objective.caloriesFor(maintenanceCalories: 2800),
        greaterThan(objective.caloriesFor(maintenanceCalories: 2000)),
        reason: objective.name,
      );
    }
  });

  test('the suggested macros total the suggested calories', () {
    for (final objective in FitnessObjective.values) {
      final goals = objective.goalsFor(maintenanceCalories: maintenanceCalories);

      expect(goals.calorieGoal, closeTo(objective.caloriesFor(maintenanceCalories: maintenanceCalories), 0.001), reason: objective.name);
    }
  });

  test('building muscle is a high-protein diet, so the objective carries the modality', () {
    expect(FitnessObjective.gainMuscle.modality, DietModality.highProtein);
    expect(FitnessObjective.maintainWeight.modality, DietModality.balanced);
  });

  test('the saved grams read back as the objective own modality, so the goals page needs no wiring', () {
    for (final objective in FitnessObjective.values) {
      final goals = objective.goalsFor(maintenanceCalories: maintenanceCalories);

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
