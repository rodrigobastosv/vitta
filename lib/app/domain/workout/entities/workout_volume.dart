import 'package:vitta/app/domain/workout/entities/workout_set.dart';

// The totals belong to the list of sets, so a caller holding a bare list - the
// previous session's sets, say (see SessionProgress) - gets them without having to
// be an entity first. WorkoutVolume forwards, so everything that mixes it in reads
// exactly as before.
extension WorkoutSetTotals on List<WorkoutSet> {
  double get volumeKg => fold(0, (sum, set) => sum + set.volumeKg);

  int get totalReps => fold(0, (sum, set) => sum + (set.reps ?? 0));

  double get heaviestWeightKg => fold(0, (heaviest, set) => set.weightKg > heaviest ? set.weightKg : heaviest);

  int get totalDurationSeconds => fold(0, (sum, set) => sum + (set.durationSeconds ?? 0));

  double get totalDistanceMeters => fold(0, (sum, set) => sum + (set.distanceMeters ?? 0));
}

mixin WorkoutVolume {
  List<WorkoutSet> get sets;

  double get volumeKg => sets.volumeKg;

  int get totalSets => sets.length;

  int get totalReps => sets.totalReps;

  double get heaviestWeightKg => sets.heaviestWeightKg;

  int get totalDurationSeconds => sets.totalDurationSeconds;

  double get totalDistanceMeters => sets.totalDistanceMeters;

  bool get hasCardio => sets.any((set) => set.isCardio);
}
