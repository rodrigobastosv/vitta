import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/basal_metabolism.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class ObjectiveState extends Equatable {
  const ObjectiveState({
    this.objective,
    this.heightCm = BodyProfile.defaultHeightCm,
    this.weightKg = BodyProfile.defaultWeightKg,
    this.sex,
    this.birthDate,
    this.activityLevel,
    this.hasWeighIn = false,
    this.isLoaded = false,
  });

  final FitnessObjective? objective;
  final double heightCm;
  final double weightKg;
  final BiologicalSex? sex;
  final DateTime? birthDate;
  final ActivityLevel? activityLevel;
  // Whether weightKg came from a real weigh-in or is the assumed default, so the
  // page can say which - a target computed from a body nobody entered should not
  // read as if it were measured.
  final bool hasWeighIn;
  final bool isLoaded;

  BodyProfile get profile => BodyProfile(heightCm: heightCm, objective: objective, sex: sex, birthDate: birthDate, activityLevel: activityLevel);

  BasalMetabolism get metabolism => BasalMetabolism.fromProfile(profile: profile, weightKg: weightKg);

  int get ageYears => profile.effectiveAgeYears;

  MacroGoals? get goals => objective?.goalsFor(maintenanceCalories: metabolism.maintenanceCalories);

  bool get canSave => objective != null;

  ObjectiveState copyWith({
    FitnessObjective? objective,
    double? heightCm,
    double? weightKg,
    BiologicalSex? sex,
    DateTime? birthDate,
    ActivityLevel? activityLevel,
    bool? hasWeighIn,
    bool? isLoaded,
  }) => ObjectiveState(
    objective: objective ?? this.objective,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    sex: sex ?? this.sex,
    birthDate: birthDate ?? this.birthDate,
    activityLevel: activityLevel ?? this.activityLevel,
    hasWeighIn: hasWeighIn ?? this.hasWeighIn,
    isLoaded: isLoaded ?? this.isLoaded,
  );

  @override
  List<Object?> get props => [objective, heightCm, weightKg, sex, birthDate, activityLevel, hasWeighIn, isLoaded];
}
