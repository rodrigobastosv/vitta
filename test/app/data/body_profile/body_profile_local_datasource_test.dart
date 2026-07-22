import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/body_profile/body_profile_local_datasource.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';

import '../../../fixtures/local_storage_fixture.dart';

void main() {
  test('an unset profile reads back empty, so nothing is derived from an assumption', () async {
    final dataSource = BodyProfileLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getProfile(), const BodyProfile());
  });

  test('the objective survives a round trip', () async {
    final dataSource = BodyProfileLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveProfile(const BodyProfile(heightCm: 178, objective: FitnessObjective.gainMuscle));

    expect(dataSource.getProfile(), const BodyProfile(heightCm: 178, objective: FitnessObjective.gainMuscle));
  });

  test('switching objective replaces the stored one', () async {
    final dataSource = BodyProfileLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveProfile(const BodyProfile(heightCm: 178, objective: FitnessObjective.loseWeight));
    await dataSource.saveProfile(const BodyProfile(heightCm: 178, objective: FitnessObjective.maintainWeight));

    expect(dataSource.getProfile().objective, FitnessObjective.maintainWeight);
  });
}
