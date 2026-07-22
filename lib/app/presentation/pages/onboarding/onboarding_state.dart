import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/basal_metabolism.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = 0,
    this.weightKg = BodyProfile.defaultWeightKg,
    this.heightCm = BodyProfile.defaultHeightCm,
    this.sex,
    this.birthDate,
    this.activityLevel,
    this.objective = .maintainWeight,
    this.calorieGoal,
    this.bodyProvided = false,
    this.goalsAccepted = false,
  });

  static const int stepCount = 5;

  final int step;
  final double weightKg;
  final double heightCm;
  final BiologicalSex? sex;
  final DateTime? birthDate;
  final ActivityLevel? activityLevel;
  final FitnessObjective objective;
  // Null means "still following the suggestion", so changing the body or the
  // objective moves the target with it; once the user drags the slider their own
  // number wins and the suggestion stops overriding it.
  final double? calorieGoal;
  final bool bodyProvided;
  final bool goalsAccepted;

  bool get isLastStep => step == stepCount - 1;

  BodyProfile get profile => BodyProfile(heightCm: heightCm, objective: objective, sex: sex, birthDate: birthDate, activityLevel: activityLevel);

  BasalMetabolism get metabolism => BasalMetabolism.fromProfile(profile: profile, weightKg: weightKg);

  int get ageYears => profile.effectiveAgeYears;

  MacroGoals get suggestedGoals => objective.goalsFor(maintenanceCalories: metabolism.maintenanceCalories);

  double get effectiveCalorieGoal => calorieGoal ?? suggestedGoals.calorieGoal;

  MacroGoals get goals => suggestedGoals.withScaledCalories(effectiveCalorieGoal);

  OnboardingState copyWith({int? step, double? calorieGoal, bool? bodyProvided, bool? goalsAccepted}) => OnboardingState(
    step: step ?? this.step,
    weightKg: weightKg,
    heightCm: heightCm,
    sex: sex,
    birthDate: birthDate,
    activityLevel: activityLevel,
    objective: objective,
    calorieGoal: calorieGoal ?? this.calorieGoal,
    bodyProvided: bodyProvided ?? this.bodyProvided,
    goalsAccepted: goalsAccepted ?? this.goalsAccepted,
  );

  // Rebuilt rather than copied, because a new body or objective has to drop the
  // slider's override back to null - which copyWith cannot express, the same
  // reason AuthState rebuilds for its draft avatar.
  OnboardingState withBody({
    double? weightKg,
    double? heightCm,
    BiologicalSex? sex,
    DateTime? birthDate,
    ActivityLevel? activityLevel,
    FitnessObjective? objective,
  }) => OnboardingState(
    step: step,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    sex: sex ?? this.sex,
    birthDate: birthDate ?? this.birthDate,
    activityLevel: activityLevel ?? this.activityLevel,
    objective: objective ?? this.objective,
    bodyProvided: bodyProvided,
    goalsAccepted: goalsAccepted,
  );

  @override
  List<Object?> get props => [step, weightKg, heightCm, sex, birthDate, activityLevel, objective, calorieGoal, bodyProvided, goalsAccepted];
}
