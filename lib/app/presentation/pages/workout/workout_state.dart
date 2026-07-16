import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class WorkoutState extends Equatable with WorkoutVolume {
  const WorkoutState({
    required this.date,
    required this.workouts,
    this.cycle = const RoutineCycle(routines: []),
    this.lastSetsByExercise = const {},
  });

  final DateTime date;
  final List<Workout> workouts;

  final RoutineCycle cycle;

  final Map<String, List<WorkoutSet>> lastSetsByExercise;

  Workout? get workout => workouts.firstOrNull;

  bool get isEmpty => workouts.every((workout) => workout.exercises.isEmpty);

  List<WorkoutExercise> get exercises => [for (final workout in workouts) ...workout.exercises];

  int get completedExercises => exercises.where((exercise) => exercise.isCompleted).length;

  bool get isFinished => workouts.isNotEmpty && workouts.every((workout) => workout.isComplete);

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  List<WorkoutSet> get sets => [for (final workout in workouts) ...workout.sets];

  WorkoutState copyWith({
    DateTime? date,
    List<Workout>? workouts,
    RoutineCycle? cycle,
    Map<String, List<WorkoutSet>>? lastSetsByExercise,
  }) => WorkoutState(
    date: date ?? this.date,
    workouts: workouts ?? this.workouts,
    cycle: cycle ?? this.cycle,
    lastSetsByExercise: lastSetsByExercise ?? this.lastSetsByExercise,
  );

  @override
  List<Object?> get props => [date, workouts, cycle, lastSetsByExercise];
}
