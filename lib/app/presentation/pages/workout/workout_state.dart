import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class WorkoutState extends Equatable with WorkoutVolume {
  const WorkoutState({required this.date, required this.workouts, this.cycle = const RoutineCycle(routines: [])});

  final DateTime date;
  final List<Workout> workouts;

  /// The user's routines and where they are in the cycle. Empty until loaded,
  /// and legitimately empty for someone who never made a routine - the one-off
  /// FAB path stays the whole feature for them.
  final RoutineCycle cycle;

  /// The day's first workout, which is what the page edits. A second workout on
  /// the same date is possible (a two-a-day) and is rendered read-through, but
  /// adding an exercise always targets this one.
  Workout? get workout => workouts.firstOrNull;

  bool get isEmpty => workouts.every((workout) => workout.exercises.isEmpty);

  List<WorkoutExercise> get exercises => [for (final workout in workouts) ...workout.exercises];

  int get completedExercises => exercises.where((exercise) => exercise.isCompleted).length;

  /// Whether the day being shown is today. Starting a routine is only offered
  /// here: you can't begin a session in the past, and the day selector already
  /// refuses to go past today. Past days stay fully editable - fixing a set you
  /// forgot to log is different from starting the workout.
  /// Every exercise of the day marked done. Drives the end-of-workout message.
  bool get isFinished => workouts.isNotEmpty && workouts.every((workout) => workout.isComplete);

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  List<WorkoutSet> get sets => [for (final workout in workouts) ...workout.sets];

  WorkoutState copyWith({DateTime? date, List<Workout>? workouts, RoutineCycle? cycle}) =>
      WorkoutState(date: date ?? this.date, workouts: workouts ?? this.workouts, cycle: cycle ?? this.cycle);

  @override
  List<Object?> get props => [date, workouts, cycle];
}
