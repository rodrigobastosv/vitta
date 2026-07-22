import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';

// The durable facts about the user's body that are not a time series (issue
// #179). Weight deliberately is not one of them - it changes constantly and
// already lives in body_weight_logs, so the objective page reads the latest
// weigh-in rather than keeping a stale copy here.
//
// Both fields are nullable because a user can skip the onboarding body step: no
// objective means no derived goals, which is what makes "the modality is derived
// from the objective, if any" expressible.
class BodyProfile extends Equatable {
  const BodyProfile({this.heightCm, this.objective});

  // What to assume when the user has not told us. The weight default sits here
  // rather than on a weight entity because this is the one place that knows what
  // a body looks like when nothing about it is known.
  static const double defaultHeightCm = 170;
  static const double defaultWeightKg = 70;

  final double? heightCm;
  final FitnessObjective? objective;

  double get effectiveHeightCm => heightCm ?? defaultHeightCm;

  BodyProfile copyWith({double? heightCm, FitnessObjective? objective}) =>
      BodyProfile(heightCm: heightCm ?? this.heightCm, objective: objective ?? this.objective);

  @override
  List<Object?> get props => [heightCm, objective];
}
