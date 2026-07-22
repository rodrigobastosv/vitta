import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = 0,
    this.weightKg = defaultWeightKg,
    this.heightCm = defaultHeightCm,
    this.objective = FitnessObjective.maintainWeight,
    this.calorieGoal,
    this.bodyProvided = false,
    this.goalsAccepted = false,
  });

  static const int stepCount = 5;
  static const double defaultWeightKg = 70;
  static const double defaultHeightCm = 170;

  final int step;
  final double weightKg;
  final double heightCm;
  final FitnessObjective objective;
  // Null means "still following the suggestion", so changing the body or the
  // objective moves the target with it; once the user drags the slider their own
  // number wins and the suggestion stops overriding it.
  final double? calorieGoal;
  final bool bodyProvided;
  final bool goalsAccepted;

  bool get isLastStep => step == stepCount - 1;

  MacroGoals get suggestedGoals => objective.goalsFor(weightKg: weightKg, heightCm: heightCm);

  double get effectiveCalorieGoal => calorieGoal ?? suggestedGoals.calorieGoal;

  MacroGoals get goals => suggestedGoals.withScaledCalories(effectiveCalorieGoal);

  OnboardingState copyWith({int? step, double? calorieGoal, bool? bodyProvided, bool? goalsAccepted}) => OnboardingState(
    step: step ?? this.step,
    weightKg: weightKg,
    heightCm: heightCm,
    objective: objective,
    calorieGoal: calorieGoal ?? this.calorieGoal,
    bodyProvided: bodyProvided ?? this.bodyProvided,
    goalsAccepted: goalsAccepted ?? this.goalsAccepted,
  );

  // Rebuilt rather than copied, because a new body or objective has to drop the
  // slider's override back to null - which copyWith cannot express, the same
  // reason AuthState rebuilds for its draft avatar.
  OnboardingState withBody({double? weightKg, double? heightCm, FitnessObjective? objective}) => OnboardingState(
    step: step,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    objective: objective ?? this.objective,
    bodyProvided: bodyProvided,
    goalsAccepted: goalsAccepted,
  );

  @override
  List<Object?> get props => [step, weightKg, heightCm, objective, calorieGoal, bodyProvided, goalsAccepted];
}
