import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';

// The durable facts about the user's body that are not a time series (issue
// #179). Weight deliberately is not one of them - it changes constantly and
// already lives in body_weight_logs, so the objective page reads the latest
// weigh-in rather than keeping a stale copy here.
//
// Every field is nullable because a user can skip the onboarding body step, and
// because the metabolic estimate (issue #169) has to stay total when it is only
// half answered: an unknown sex, age or activity level falls back to a stated
// assumption rather than blocking the estimate.
class BodyProfile extends Equatable {
  const BodyProfile({this.heightCm, this.objective, this.sex, this.birthDate, this.activityLevel});

  // What to assume when the user has not told us. The weight default sits here
  // rather than on a weight entity because this is the one place that knows what
  // a body looks like when nothing about it is known.
  static const double defaultHeightCm = 170;
  static const double defaultWeightKg = 70;
  static const int defaultAgeYears = 30;
  static const ActivityLevel defaultActivityLevel = .lightlyActive;

  static DateTime birthDateForAge(int ageYears, [DateTime? now]) {
    final today = now ?? DateTime.now();
    return DateTime(today.year - ageYears, today.month, today.day);
  }

  final double? heightCm;
  final FitnessObjective? objective;
  final BiologicalSex? sex;
  // The age question is asked as an age but stored as the birth date it implies,
  // so the estimate ages with the user instead of freezing at the number typed
  // once during onboarding.
  final DateTime? birthDate;
  final ActivityLevel? activityLevel;

  double get effectiveHeightCm => heightCm ?? defaultHeightCm;

  int? ageAt(DateTime now) {
    final birth = birthDate;
    if (birth == null) {
      return null;
    }
    final years = now.year - birth.year;
    final hadBirthday = now.month > birth.month || (now.month == birth.month && now.day >= birth.day);
    return hadBirthday ? years : years - 1;
  }

  int? get ageYears => ageAt(DateTime.now());

  int get effectiveAgeYears => ageYears ?? defaultAgeYears;

  ActivityLevel get effectiveActivityLevel => activityLevel ?? defaultActivityLevel;

  bool get hasMetabolicInputs => sex != null && birthDate != null && activityLevel != null;

  BodyProfile copyWith({double? heightCm, FitnessObjective? objective, BiologicalSex? sex, DateTime? birthDate, ActivityLevel? activityLevel}) => BodyProfile(
    heightCm: heightCm ?? this.heightCm,
    objective: objective ?? this.objective,
    sex: sex ?? this.sex,
    birthDate: birthDate ?? this.birthDate,
    activityLevel: activityLevel ?? this.activityLevel,
  );

  @override
  List<Object?> get props => [heightCm, objective, sex, birthDate, activityLevel];
}
