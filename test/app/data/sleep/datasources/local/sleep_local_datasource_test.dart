import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/sleep/datasources/local/sleep_local_datasource.dart';

import '../../../../../fixtures/local_storage_fixture.dart';

void main() {
  test('getDurationGoalHours defaults when nothing was saved', () async {
    final dataSource = SleepLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getDurationGoalHours(), SleepLocalDataSource.defaultDurationGoalHours);
  });

  test('saveDurationGoalHours persists and reads back', () async {
    final dataSource = SleepLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveDurationGoalHours(7.5);

    expect(dataSource.getDurationGoalHours(), 7.5);
  });

  test('getLastSyncedAt is null when never synced', () async {
    final dataSource = SleepLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getLastSyncedAt(), isNull);
  });

  test('saveLastSyncedAt persists a timestamp read back to the same instant', () async {
    final dataSource = SleepLocalDataSource(localStorageService: await buildTestLocalStorageService());
    final syncedAt = DateTime(2026, 7, 21, 14, 30);

    await dataSource.saveLastSyncedAt(syncedAt);

    expect(dataSource.getLastSyncedAt(), syncedAt);
  });
}
