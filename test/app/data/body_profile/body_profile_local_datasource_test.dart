import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/body_profile/body_profile_local_datasource.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
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

    await dataSource.saveProfile(const BodyProfile(heightCm: 178, objective: .gainMuscle));

    expect(dataSource.getProfile(), const BodyProfile(heightCm: 178, objective: .gainMuscle));
  });

  test('the metabolic inputs survive a round trip', () async {
    final dataSource = BodyProfileLocalDataSource(localStorageService: await buildTestLocalStorageService());
    final profile = BodyProfile(
      heightCm: 178,
      objective: .gainMuscle,
      sex: .female,
      birthDate: DateTime(1994, 5, 6),
      activityLevel: .veryActive,
    );

    await dataSource.saveProfile(profile);

    expect(dataSource.getProfile(), profile);
  });

  test('a half-answered profile keeps its gaps rather than inventing values', () async {
    final dataSource = BodyProfileLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveProfile(const BodyProfile(heightCm: 178, sex: .male));

    final stored = dataSource.getProfile();

    expect(stored.sex, BiologicalSex.male);
    expect(stored.birthDate, isNull);
    expect(stored.activityLevel, isNull);
  });

  test('switching objective replaces the stored one', () async {
    final dataSource = BodyProfileLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveProfile(const BodyProfile(heightCm: 178, objective: .loseWeight));
    await dataSource.saveProfile(const BodyProfile(heightCm: 178, objective: .maintainWeight));

    expect(dataSource.getProfile().objective, FitnessObjective.maintainWeight);
  });
}
