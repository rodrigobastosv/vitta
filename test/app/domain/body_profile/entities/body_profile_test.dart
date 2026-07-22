import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';

void main() {
  test('the age asked for is the age read back, whatever day of the year it is', () {
    for (final age in [14, 30, 67, 100]) {
      expect(BodyProfile(birthDate: BodyProfile.birthDateForAge(age)).ageYears, age, reason: '$age');
    }
  });

  test('a birthday still to come this year has not been counted yet', () {
    final now = DateTime(2026, 3, 10);
    final beforeBirthday = BodyProfile(birthDate: DateTime(1990, 3, 11));
    final onBirthday = BodyProfile(birthDate: DateTime(1990, 3, 10));

    expect(beforeBirthday.ageAt(now), 35);
    expect(onBirthday.ageAt(now), 36);
  });

  test('a stored birth date ages the estimate instead of freezing the number typed once', () {
    final profile = BodyProfile(birthDate: BodyProfile.birthDateForAge(30, DateTime(2026, 7, 22)));

    expect(profile.ageAt(DateTime(2026, 7, 22)), 30);
    expect(profile.ageAt(DateTime(2031, 7, 22)), 35);
  });

  test('an unanswered profile still answers, with the assumptions it names', () {
    const profile = BodyProfile();

    expect(profile.ageYears, isNull);
    expect(profile.effectiveAgeYears, BodyProfile.defaultAgeYears);
    expect(profile.effectiveHeightCm, BodyProfile.defaultHeightCm);
    expect(profile.effectiveActivityLevel, BodyProfile.defaultActivityLevel);
    expect(profile.hasMetabolicInputs, isFalse);
  });

  test('every metabolic input answered is what makes the estimate measured', () {
    final profile = BodyProfile(sex: .male, birthDate: BodyProfile.birthDateForAge(30), activityLevel: .moderatelyActive);

    expect(profile.hasMetabolicInputs, isTrue);
  });
}
