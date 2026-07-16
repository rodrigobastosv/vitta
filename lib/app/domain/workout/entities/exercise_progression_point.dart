import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class ExerciseProgressionPoint extends Equatable with WorkoutVolume {
  const ExerciseProgressionPoint({required this.date, required this.sets});

  final DateTime date;

  @override
  final List<WorkoutSet> sets;

  double get estimatedOneRepMax => sets.fold(0, (best, set) => set.estimatedOneRepMax > best ? set.estimatedOneRepMax : best);

  @override
  List<Object?> get props => [date, sets];
}
