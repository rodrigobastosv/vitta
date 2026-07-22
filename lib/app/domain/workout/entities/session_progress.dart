import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

enum SessionProgressDirection { first, up, flat, down }

// How one exercise went against the last time it was trained (issue #168) - the
// question a finished session actually answers: did the numbers move?
//
// It compares against the sets WorkoutState already holds for the *previous*
// session (GetLastSetsByExerciseUseCase is queried with `before: date`), so this is
// a pure comparison of two lists: no new query, and no notion of a goal.
class SessionProgress extends Equatable {
  const SessionProgress({required this.exercise, required this.previousSets});

  final WorkoutExercise exercise;
  final List<WorkoutSet> previousSets;

  List<WorkoutSet> get sets => exercise.sets;

  bool get isFirstTime => previousSets.isEmpty;

  double get volumeDeltaKg => sets.volumeKg - previousSets.volumeKg;

  double get heaviestDeltaKg => sets.heaviestWeightKg - previousSets.heaviestWeightKg;

  int get durationDeltaSeconds => sets.totalDurationSeconds - previousSets.totalDurationSeconds;

  // Cardio moves on time, not tonnage: a treadmill effort has no volume, so
  // comparing it that way would report every run as unchanged.
  double get _delta => exercise.isCardio ? durationDeltaSeconds.toDouble() : volumeDeltaKg;

  SessionProgressDirection get direction {
    if (isFirstTime) {
      return .first;
    }
    if (_delta > 0) {
      return .up;
    }
    return _delta < 0 ? .down : .flat;
  }

  @override
  List<Object?> get props => [exercise, previousSets];
}
