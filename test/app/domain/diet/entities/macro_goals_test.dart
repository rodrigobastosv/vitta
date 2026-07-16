import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

import '../../../../factories/entities/macro_goals_factory.dart';

void main() {
  test('calorieGoal is the energy of the macros (4/4/9, fiber excluded)', () {
    final goals = MacroGoalsFactory.build();

    expect(goals.calorieGoal, 2185);
  });

  test('editing a macro moves the calorie goal with it', () {
    final before = MacroGoalsFactory.build();
    final after = MacroGoalsFactory.build(fatGoalGrams: 75);

    expect(after.calorieGoal - before.calorieGoal, 90);
  });

  test('fiber carries no energy, so it never changes the calorie goal', () {
    final low = MacroGoalsFactory.build(fiberGoalGrams: 10);
    final high = MacroGoalsFactory.build(fiberGoalGrams: 50);

    expect(low.calorieGoal, high.calorieGoal);
  });

  test('the min/max band is the calorie goal at plus or minus 10 percent', () {
    final goals = MacroGoalsFactory.build(proteinGoalGrams: 100, carbsGoalGrams: 100, fatGoalGrams: 0, fiberGoalGrams: 20);

    expect(goals.calorieGoal, 800);
    expect(goals.calorieMin, closeTo(720, 0.001));
    expect(goals.calorieMax, closeTo(880, 0.001));
  });

  test('withScaledCalories hits the new calorie total keeping macro proportions', () {
    final goals = MacroGoalsFactory.build(proteinGoalGrams: 100, carbsGoalGrams: 200, fatGoalGrams: 50);

    final scaled = goals.withScaledCalories(goals.calorieGoal * 2);

    expect(scaled.calorieGoal, closeTo(goals.calorieGoal * 2, 0.001));
    expect(scaled.proteinGoalGrams, 200);
    expect(scaled.carbsGoalGrams, 400);
    expect(scaled.fatGoalGrams, 100);
  });

  test('withScaledCalories leaves fiber untouched', () {
    final goals = MacroGoalsFactory.build(fiberGoalGrams: 25);

    expect(goals.withScaledCalories(goals.calorieGoal * 1.5).fiberGoalGrams, 25);
  });

  test('withScaledCalories falls back to a balanced split when there are no macros to scale', () {
    const goals = MacroGoals(proteinGoalGrams: 0, carbsGoalGrams: 0, fatGoalGrams: 0, fiberGoalGrams: 20);

    final scaled = goals.withScaledCalories(2000);

    expect(scaled.calorieGoal, closeTo(2000, 0.001));
    expect(scaled.proteinGoalGrams, greaterThan(0));
    expect(scaled.carbsGoalGrams, greaterThan(0));
    expect(scaled.fatGoalGrams, greaterThan(0));
  });
}
