import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class DailyWorkout extends Equatable with WorkoutVolume {
  const DailyWorkout({required this.date, required this.workouts});

  final DateTime date;
  final List<Workout> workouts;

  bool get hasData => workouts.isNotEmpty;

  List<WorkoutExercise> get exercises => [for (final workout in workouts) ...workout.exercises];

  @override
  List<WorkoutSet> get sets => [for (final workout in workouts) ...workout.sets];

  @override
  List<Object?> get props => [date, workouts];
}
