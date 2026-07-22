import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_energy.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class WorkoutState extends Equatable with WorkoutVolume, WorkoutEnergy {
  const WorkoutState({
    required this.date,
    required this.workouts,
    this.cycle = const RoutineCycle(routines: []),
    this.lastSetsByExercise = const {},
    this.latestBodyWeightKg,
    this.isLoaded = true,
  });

  final DateTime date;
  final List<Workout> workouts;

  final RoutineCycle cycle;

  final Map<String, List<WorkoutSet>> lastSetsByExercise;

  // The user's most recent body weight (issue #101), used to pre-fill the load for
  // bodyweight exercises. Null when nothing has been logged.
  final double? latestBodyWeightKg;
  final bool isLoaded;

  Workout? get workout => workouts.firstOrNull;

  bool get isEmpty => workouts.every((workout) => workout.exercises.isEmpty);

  @override
  List<WorkoutExercise> get exercises => [for (final workout in workouts) ...workout.exercises];

  bool get isBodyWeightKnown => latestBodyWeightKg != null;

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
    double? latestBodyWeightKg,
    bool? isLoaded,
  }) => WorkoutState(
    isLoaded: isLoaded ?? this.isLoaded,
    date: date ?? this.date,
    workouts: workouts ?? this.workouts,
    cycle: cycle ?? this.cycle,
    lastSetsByExercise: lastSetsByExercise ?? this.lastSetsByExercise,
    latestBodyWeightKg: latestBodyWeightKg ?? this.latestBodyWeightKg,
  );

  @override
  List<Object?> get props => [isLoaded, date, workouts, cycle, lastSetsByExercise, latestBodyWeightKg];
}
