import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/set_kind.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class SetInput extends Equatable {
  const SetInput.strength({required this.reps, required this.weightKg}) : durationSeconds = null, distanceMeters = null;

  const SetInput.cardio({required this.durationSeconds, this.distanceMeters}) : reps = null, weightKg = 0;

  factory SetInput.fromSet(WorkoutSet set) => set.isCardio
      ? SetInput.cardio(durationSeconds: set.durationSeconds, distanceMeters: set.distanceMeters)
      : SetInput.strength(reps: set.reps ?? 0, weightKg: set.weightKg);

  final int? reps;
  final double weightKg;
  final int? durationSeconds;
  final double? distanceMeters;

  SetKind get kind => durationSeconds != null ? SetKind.cardio : SetKind.strength;

  @override
  List<Object?> get props => [reps, weightKg, durationSeconds, distanceMeters];
}
