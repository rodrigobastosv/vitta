import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';

class BasalMetabolism extends Equatable {
  const BasalMetabolism({required this.weightKg, required this.heightCm, this.sex, this.ageYears, this.activityLevel});

  factory BasalMetabolism.fromProfile({required BodyProfile profile, required double weightKg}) => BasalMetabolism(
    weightKg: weightKg,
    heightCm: profile.effectiveHeightCm,
    sex: profile.sex,
    ageYears: profile.ageYears,
    activityLevel: profile.activityLevel,
  );

  static const double _weightCoefficient = 10;
  static const double _heightCoefficient = 6.25;
  static const double _ageCoefficient = 5;

  final double weightKg;
  final double heightCm;
  final BiologicalSex? sex;
  final int? ageYears;
  final ActivityLevel? activityLevel;

  int get effectiveAgeYears => ageYears ?? BodyProfile.defaultAgeYears;

  ActivityLevel get effectiveActivityLevel => activityLevel ?? BodyProfile.defaultActivityLevel;

  double get sexConstant => sex?.mifflinConstant ?? BiologicalSex.unknownMifflinConstant;

  bool get isFullyKnown => sex != null && ageYears != null && activityLevel != null;

  double get basalCalories =>
      _weightCoefficient * weightKg + _heightCoefficient * heightCm - _ageCoefficient * effectiveAgeYears + sexConstant;

  double get maintenanceCalories => basalCalories * effectiveActivityLevel.multiplier;

  @override
  List<Object?> get props => [weightKg, heightCm, sex, ageYears, activityLevel];
}
