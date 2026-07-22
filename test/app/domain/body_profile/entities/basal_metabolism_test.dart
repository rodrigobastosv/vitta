import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/basal_metabolism.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';

void main() {
  test('the basal figure is Mifflin-St Jeor, to the published worked example', () {
    const man = BasalMetabolism(weightKg: 80, heightCm: 180, sex: .male, ageYears: 30);
    const woman = BasalMetabolism(weightKg: 80, heightCm: 180, sex: .female, ageYears: 30);

    expect(man.basalCalories, closeTo(10 * 80 + 6.25 * 180 - 5 * 30 + 5, 0.001));
    expect(woman.basalCalories, closeTo(10 * 80 + 6.25 * 180 - 5 * 30 - 161, 0.001));
  });

  test('sex is worth 166 kcal, which is why it is asked for', () {
    const man = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 40);
    const woman = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .female, ageYears: 40);

    expect(man.basalCalories - woman.basalCalories, closeTo(166, 0.001));
  });

  test('an unknown sex lands between the two, so the estimate stays total', () {
    const unknown = BasalMetabolism(weightKg: 70, heightCm: 170, ageYears: 40);
    const man = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 40);
    const woman = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .female, ageYears: 40);

    expect(unknown.basalCalories, lessThan(man.basalCalories));
    expect(unknown.basalCalories, greaterThan(woman.basalCalories));
  });

  test('age lowers the figure and weight and height raise it', () {
    const younger = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 25);
    const older = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 55);
    const heavier = BasalMetabolism(weightKg: 90, heightCm: 170, sex: .male, ageYears: 25);
    const taller = BasalMetabolism(weightKg: 70, heightCm: 190, sex: .male, ageYears: 25);

    expect(older.basalCalories, lessThan(younger.basalCalories));
    expect(heavier.basalCalories, greaterThan(younger.basalCalories));
    expect(taller.basalCalories, greaterThan(younger.basalCalories));
  });

  test('maintenance is the basal figure times the activity multiplier', () {
    for (final level in ActivityLevel.values) {
      final metabolism = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 30, activityLevel: level);

      expect(metabolism.maintenanceCalories, closeTo(metabolism.basalCalories * level.multiplier, 0.001), reason: level.name);
    }
  });

  test('a busier day never burns less than a quieter one', () {
    final maintenances = [
      for (final level in ActivityLevel.values) BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 30, activityLevel: level).maintenanceCalories,
    ];

    for (var index = 1; index < maintenances.length; index++) {
      expect(maintenances[index], greaterThan(maintenances[index - 1]));
    }
  });

  test('an unset activity level falls back to the stated assumption rather than to nothing', () {
    const unset = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 30);
    const assumed = BasalMetabolism(weightKg: 70, heightCm: 170, sex: .male, ageYears: 30, activityLevel: BodyProfile.defaultActivityLevel);

    expect(unset.maintenanceCalories, assumed.maintenanceCalories);
    expect(unset.isFullyKnown, isFalse);
    expect(unset.effectiveAgeYears, 30);
  });

  test('a fully answered profile reports itself as measured rather than assumed', () {
    final profile = BodyProfile(
      heightCm: 175,
      sex: .female,
      birthDate: BodyProfile.birthDateForAge(28),
      activityLevel: .veryActive,
    );
    final metabolism = BasalMetabolism.fromProfile(profile: profile, weightKg: 62);

    expect(metabolism.isFullyKnown, isTrue);
    expect(metabolism.heightCm, 175);
    expect(metabolism.ageYears, 28);
    expect(metabolism.weightKg, 62);
  });

  test('an empty profile still estimates, from the defaults it names', () {
    final metabolism = BasalMetabolism.fromProfile(profile: const BodyProfile(), weightKg: BodyProfile.defaultWeightKg);

    expect(metabolism.isFullyKnown, isFalse);
    expect(metabolism.heightCm, BodyProfile.defaultHeightCm);
    expect(metabolism.effectiveAgeYears, BodyProfile.defaultAgeYears);
    expect(metabolism.effectiveActivityLevel, BodyProfile.defaultActivityLevel);
    expect(metabolism.basalCalories, greaterThan(0));
  });

  test('an activity level and a sex survive a round trip through their wire values', () {
    for (final level in ActivityLevel.values) {
      expect(ActivityLevel.fromWireValue(level.wireValue), level);
    }
    for (final sex in BiologicalSex.values) {
      expect(BiologicalSex.fromWireValue(sex.wireValue), sex);
    }
    expect(ActivityLevel.fromWireValue(null), isNull);
    expect(BiologicalSex.fromWireValue('other'), isNull);
  });
}
