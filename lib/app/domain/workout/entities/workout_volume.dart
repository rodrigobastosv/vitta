import 'package:vitta/app/domain/workout/entities/workout_set.dart';

mixin WorkoutVolume {
  List<WorkoutSet> get sets;

  double get volumeKg => sets.fold(0, (sum, set) => sum + set.volumeKg);

  int get totalSets => sets.length;

  int get totalReps => sets.fold(0, (sum, set) => sum + (set.reps ?? 0));

  double get heaviestWeightKg => sets.fold(0, (heaviest, set) => set.weightKg > heaviest ? set.weightKg : heaviest);

  int get totalDurationSeconds => sets.fold(0, (sum, set) => sum + (set.durationSeconds ?? 0));

  double get totalDistanceMeters => sets.fold(0, (sum, set) => sum + (set.distanceMeters ?? 0));

  bool get hasCardio => sets.any((set) => set.isCardio);
}
