import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

import '../../../../factories/entities/macro_goals_factory.dart';

void main() {
  test('applyTo re-splits the current calorie goal by the modality ratios', () {
    final goals = MacroGoalsFactory.build();
    final calories = goals.calorieGoal;

    final balanced = DietModality.balanced.applyTo(goals);

    expect(balanced.proteinGoalGrams, closeTo(calories * 0.30 / 4, 0.001));
    expect(balanced.carbsGoalGrams, closeTo(calories * 0.40 / 4, 0.001));
    expect(balanced.fatGoalGrams, closeTo(calories * 0.30 / 9, 0.001));
  });

  test('applyTo keeps the calorie total and the fiber goal', () {
    final goals = MacroGoalsFactory.build(fiberGoalGrams: 42);

    final keto = DietModality.keto.applyTo(goals);

    expect(keto.calorieGoal, closeTo(goals.calorieGoal, 0.001));
    expect(keto.fiberGoalGrams, 42);
  });

  test('applyTo builds on a 2000 kcal fallback when the goals carry no energy', () {
    const goals = MacroGoals(proteinGoalGrams: 0, carbsGoalGrams: 0, fatGoalGrams: 0, fiberGoalGrams: 20);

    final highProtein = DietModality.highProtein.applyTo(goals);

    expect(highProtein.calorieGoal, closeTo(2000, 0.001));
    expect(highProtein.proteinGoalGrams, closeTo(2000 * 0.40 / 4, 0.001));
  });

  test('matching recovers the modality that produced the goals', () {
    for (final modality in DietModality.values) {
      final goals = modality.applyTo(MacroGoalsFactory.build());

      expect(DietModality.matching(goals), modality, reason: '$modality should match its own output');
    }
  });

  test('changing only calories keeps the modality (proportions are preserved)', () {
    final lowCarb = DietModality.lowCarb.applyTo(MacroGoalsFactory.build());

    final scaled = lowCarb.withScaledCalories(lowCarb.calorieGoal * 1.4);

    expect(DietModality.matching(scaled), DietModality.lowCarb);
  });

  test('matching is null for a custom split no preset covers', () {
    final custom = MacroGoalsFactory.build(proteinGoalGrams: 120, carbsGoalGrams: 120, fatGoalGrams: 120);

    expect(DietModality.matching(custom), isNull);
  });

  test('matching is null when there is no energy to split', () {
    const empty = MacroGoals(proteinGoalGrams: 0, carbsGoalGrams: 0, fatGoalGrams: 0, fiberGoalGrams: 30);

    expect(DietModality.matching(empty), isNull);
  });

  test('presets do not cross-match each other', () {
    final balancedGoals = DietModality.balanced.applyTo(MacroGoalsFactory.build());

    expect(DietModality.keto.matches(balancedGoals), isFalse);
    expect(DietModality.lowFat.matches(balancedGoals), isFalse);
  });
}
