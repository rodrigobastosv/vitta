import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_gap.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';

DailyMacros _dayWith({required double grams, double caloriesPer100g = 100, double proteinPer100g = 10}) => DailyMacros(
  entries: [
    FoodLogEntryFactory.build(
      log: FoodLogFactory.build(quantityGrams: grams),
      food: FoodFactory.build(caloriesPer100g: caloriesPer100g, proteinPer100g: proteinPer100g, carbsPer100g: 0, fatPer100g: 0, fiberPer100g: 0),
    ),
  ],
);

void main() {
  const goals = MacroGoals.defaultGoals;

  test('an untouched day leaves the whole goal to fill', () {
    final gap = MacroGap.between(consumed: const DailyMacros(entries: []), goals: goals);

    expect(gap.calories, goals.calorieGoal);
    expect(gap.protein, 150);
    expect(gap.fiber, 30);
    expect(gap.isMet, isFalse);
  });

  test('what is already logged comes off the gap', () {
    final gap = MacroGap.between(consumed: _dayWith(grams: 200), goals: goals);

    expect(gap.calories, goals.calorieGoal - 200);
    expect(gap.protein, 130);
  });

  // The sign is what tells a suggestion the day is already over, so it is kept
  // rather than floored - flooring it here would read as a day landing exactly
  // on its goal.
  test('a day past its goal reports a negative gap rather than zero', () {
    final gap = MacroGap.between(consumed: _dayWith(grams: 10000), goals: goals);

    expect(gap.calories, lessThan(0));
    expect(gap.isMet, isTrue);
  });

  test('an empty log against empty goals is met', () {
    final gap = MacroGap.between(
      consumed: const DailyMacros(entries: []),
      goals: const MacroGoals(proteinGoalGrams: 0, carbsGoalGrams: 0, fatGoalGrams: 0, fiberGoalGrams: 0),
    );

    expect(gap.isMet, isTrue);
  });

  test('two gaps over the same day and goals are equal by value', () {
    expect(MacroGap.between(consumed: _dayWith(grams: 100), goals: goals), MacroGap.between(consumed: _dayWith(grams: 100), goals: goals));
  });
}
