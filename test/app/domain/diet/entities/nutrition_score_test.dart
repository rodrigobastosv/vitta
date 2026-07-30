import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/macro_nutrient.dart';
import 'package:vitta/app/domain/diet/entities/nutrient_verdict.dart';
import 'package:vitta/app/domain/diet/entities/nutrition_grade.dart';
import 'package:vitta/app/domain/diet/entities/nutrition_score.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';

// A single default 100 g portion, so a food's per-100g figures are the day's
// totals and every expectation below reads straight off the arguments.
DailyMacros _dayOf({double calories = 0, double protein = 0, double carbs = 0, double fat = 0, double fiber = 0}) => DailyMacros(
  entries: [
    FoodLogEntryFactory.build(
      food: FoodFactory.build(caloriesPer100g: calories, proteinPer100g: protein, carbsPer100g: carbs, fatPer100g: fat, fiberPer100g: fiber),
    ),
  ],
);

void main() {
  const goals = MacroGoals.defaultGoals;

  test('a day that lands on every goal scores full marks', () {
    final score = NutritionScore.of(
      consumed: _dayOf(calories: goals.calorieGoal, protein: 150, carbs: 250, fat: 65, fiber: 30),
      goals: goals,
    );

    expect(score.points, 100);
    expect(score.grade, NutritionGrade.excellent);
  });

  // Anywhere inside the same +/-10% band the calendar and the calorie ring use
  // is full marks, so the score cannot call a day off that they call met.
  test('anywhere inside the goal band still scores full marks', () {
    final score = NutritionScore.of(
      consumed: _dayOf(calories: goals.calorieGoal * 1.08, protein: 142, carbs: 262, fat: 60, fiber: 32),
      goals: goals,
    );

    expect(score.points, 100);
  });

  test('a day with nothing logged scores nothing', () {
    final score = NutritionScore.of(consumed: const DailyMacros(entries: []), goals: goals);

    expect(score.points, 0);
    expect(score.grade, NutritionGrade.poor);
  });

  test('a verdict names which side of the band a nutrient fell', () {
    final score = NutritionScore.of(
      consumed: _dayOf(calories: goals.calorieGoal, protein: 200, carbs: 250, fat: 30, fiber: 30),
      goals: goals,
    );

    expect(score.componentFor(.calories).verdict, NutrientVerdict.onTrack);
    expect(score.componentFor(.protein).verdict, NutrientVerdict.high);
    expect(score.componentFor(.fat).verdict, NutrientVerdict.low);
  });

  test('missing a goal by more than half again scores zero for that nutrient', () {
    final score = NutritionScore.of(consumed: _dayOf(protein: 30), goals: goals);

    expect(score.componentFor(.protein).fraction, 0);
  });

  // A nutrient nobody set a target for is dropped from the fold and its weight
  // redistributed, rather than being handed full marks it did not earn.
  test('a nutrient with no goal is left out instead of scored as met', () {
    const withoutFiberGoal = MacroGoals(proteinGoalGrams: 150, carbsGoalGrams: 250, fatGoalGrams: 65, fiberGoalGrams: 0);
    final onTarget = _dayOf(calories: withoutFiberGoal.calorieGoal, protein: 150, carbs: 250, fat: 65);

    final score = NutritionScore.of(consumed: onTarget, goals: withoutFiberGoal);

    expect(score.componentFor(.fiber).isScorable, isFalse);
    expect(score.scoredComponents.map((component) => component.nutrient), isNot(contains(MacroNutrient.fiber)));
    expect(score.points, 100);
  });

  test('a day with no goals at all is not scorable', () {
    const noGoals = MacroGoals(proteinGoalGrams: 0, carbsGoalGrams: 0, fatGoalGrams: 0, fiberGoalGrams: 0);

    final score = NutritionScore.of(consumed: _dayOf(calories: 2000, protein: 100), goals: noGoals);

    expect(score.isScorable, isFalse);
    expect(score.points, 0);
  });

  // The figures from the Fitia screenshot this feature is matching. Their app
  // called protein High and calories On track on exactly these numbers and graded
  // the day Excellent - reusing GoalAdherence's band reproduces all three.
  test('it reproduces the reference app on its own numbers', () {
    const fitiaGoals = MacroGoals(proteinGoalGrams: 185.4, carbsGoalGrams: 190, fatGoalGrams: 63, fiberGoalGrams: 30);
    final score = NutritionScore.of(
      consumed: _dayOf(calories: 2152, protein: 211.4, carbs: 195, fat: 48, fiber: 30),
      goals: fitiaGoals,
    );

    expect(score.componentFor(.calories).verdict, NutrientVerdict.onTrack);
    expect(score.componentFor(.protein).verdict, NutrientVerdict.high);
    expect(score.grade, NutritionGrade.excellent);
  });
}
