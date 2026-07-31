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

  test('the rest length defaults to the shipped one until the user picks their own', () async {
    final dataSource = WorkoutLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getRestSeconds(), WorkoutLocalDataSource.defaultRestSeconds);
  });

  test('a chosen rest length survives, so it is what the next launch reads', () async {
    final localStorageService = await buildTestLocalStorageService();
    await WorkoutLocalDataSource(localStorageService: localStorageService).saveRestSeconds(120);

    expect(WorkoutLocalDataSource(localStorageService: localStorageService).getRestSeconds(), 120);
  });

  test('the rest sound is on until it is turned off, and stays off', () async {
    final localStorageService = await buildTestLocalStorageService();
    final dataSource = WorkoutLocalDataSource(localStorageService: localStorageService);

    expect(dataSource.isRestSoundEnabled(), isTrue);

    await dataSource.saveRestSoundEnabled(isEnabled: false);

    expect(WorkoutLocalDataSource(localStorageService: localStorageService).isRestSoundEnabled(), isFalse);
  });
}
