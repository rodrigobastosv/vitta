import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class ObjectiveState extends Equatable {
  const ObjectiveState({
    this.objective,
    this.heightCm = BodyProfile.defaultHeightCm,
    this.weightKg = BodyProfile.defaultWeightKg,
    this.hasWeighIn = false,
    this.isLoaded = false,
  });

  final FitnessObjective? objective;
  final double heightCm;
  final double weightKg;
  // Whether weightKg came from a real weigh-in or is the assumed default, so the
  // page can say which - a target computed from a body nobody entered should not
  // read as if it were measured.
  final bool hasWeighIn;
  final bool isLoaded;

  MacroGoals? get goals => objective?.goalsFor(weightKg: weightKg, heightCm: heightCm);

  bool get canSave => objective != null;

  BodyProfile get profile => BodyProfile(heightCm: heightCm, objective: objective);

  ObjectiveState copyWith({FitnessObjective? objective, double? heightCm, double? weightKg, bool? hasWeighIn, bool? isLoaded}) => ObjectiveState(
    objective: objective ?? this.objective,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    hasWeighIn: hasWeighIn ?? this.hasWeighIn,
    isLoaded: isLoaded ?? this.isLoaded,
  );

  @override
  List<Object?> get props => [objective, heightCm, weightKg, hasWeighIn, isLoaded];
}
