import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

import '../../../../../fixtures/local_storage_fixture.dart';

void main() {
  test('getGoals defaults to MacroGoals.defaultGoals when nothing was saved', () async {
    final dataSource = DietGoalsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getGoals(), MacroGoals.defaultGoals);
  });

  test('saveGoals persists and getGoals reads it back', () async {
    final dataSource = DietGoalsLocalDataSource(localStorageService: await buildTestLocalStorageService());
    const goals = MacroGoals(calorieGoal: 2500, proteinGoalGrams: 180, carbsGoalGrams: 300, fatGoalGrams: 80, fiberGoalGrams: 35);

    await dataSource.saveGoals(goals);

    expect(dataSource.getGoals(), goals);
  });
}
