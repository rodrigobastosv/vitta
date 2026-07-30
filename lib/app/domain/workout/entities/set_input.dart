import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/set_kind.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class SetInput extends Equatable {
  const SetInput.strength({required this.reps, required this.weightKg}) : durationSeconds = null, distanceMeters = null;

  const SetInput.cardio({required this.durationSeconds, this.distanceMeters}) : reps = null, weightKg = 0;

  factory SetInput.fromSet(WorkoutSet set) => set.isCardio
      ? SetInput.cardio(durationSeconds: set.durationSeconds, distanceMeters: set.distanceMeters)
      : SetInput.strength(reps: set.reps ?? 0, weightKg: set.weightKg);

  static const String _pendingIdPrefix = 'pending-set';

  final int? reps;
  final double weightKg;
  final int? durationSeconds;
  final double? distanceMeters;

  SetKind get kind => durationSeconds != null ? SetKind.cardio : SetKind.strength;

  // The set an optimistic write shows before the server answers. Its id is a
  // sequence rather than the real row's, so a settle can find exactly the
  // placeholder it wrote even when two identical repeats are in flight.
  WorkoutSet asPendingSet({required int sequence, required int position}) => WorkoutSet(
    id: '$_pendingIdPrefix:$sequence',
    position: position,
    reps: reps,
    weightKg: weightKg,
    durationSeconds: durationSeconds,
    distanceMeters: distanceMeters,
  );

  @override
  List<Object?> get props => [reps, weightKg, durationSeconds, distanceMeters];
}
