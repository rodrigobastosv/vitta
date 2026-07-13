import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';

import '../../../../../fixtures/local_storage_fixture.dart';

void main() {
  test('getDailyGoalMl defaults to 2000 when nothing was saved', () async {
    final dataSource = WaterLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getDailyGoalMl(), WaterLocalDataSource.defaultDailyGoalMl);
  });

  test('saveDailyGoalMl persists and getDailyGoalMl reads it back', () async {
    final dataSource = WaterLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveDailyGoalMl(3000);

    expect(dataSource.getDailyGoalMl(), 3000);
  });
}
