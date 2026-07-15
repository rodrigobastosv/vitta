import 'package:vitta/app/domain/workout/entities/workout_set.dart';

mixin WorkoutVolume {
  List<WorkoutSet> get sets;

  double get volumeKg => sets.fold(0, (sum, set) => sum + set.volumeKg);

  int get totalSets => sets.length;

  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);

  double get heaviestWeightKg => sets.fold(0, (heaviest, set) => set.weightKg > heaviest ? set.weightKg : heaviest);
}
