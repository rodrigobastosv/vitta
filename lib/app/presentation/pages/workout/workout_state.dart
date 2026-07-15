import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class WorkoutState extends Equatable with WorkoutVolume {
  const WorkoutState({required this.date, required this.workouts});

  final DateTime date;
  final List<Workout> workouts;

  /// The day's first workout, which is what the page edits. A second workout on
  /// the same date is possible (a two-a-day) and is rendered read-through, but
  /// adding an exercise always targets this one.
  Workout? get workout => workouts.firstOrNull;

  bool get isEmpty => workouts.every((workout) => workout.exercises.isEmpty);

  @override
  List<WorkoutSet> get sets => [for (final workout in workouts) ...workout.sets];

  WorkoutState copyWith({DateTime? date, List<Workout>? workouts}) =>
      WorkoutState(date: date ?? this.date, workouts: workouts ?? this.workouts);

  @override
  List<Object?> get props => [date, workouts];
}
