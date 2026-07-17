import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/workout/datasources/local/workout_local_datasource.dart';

import '../../../../../fixtures/local_storage_fixture.dart';

void main() {
  test('hasSeenIntro defaults to false when nothing was saved', () async {
    final dataSource = WorkoutLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.hasSeenIntro(), isFalse);
  });

  test('markIntroSeen persists and hasSeenIntro reads it back', () async {
    final dataSource = WorkoutLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.markIntroSeen();

    expect(dataSource.hasSeenIntro(), isTrue);
  });
}
