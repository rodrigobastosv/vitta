import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

class ExerciseWorkoutExtra {
  const ExerciseWorkoutExtra({required this.workoutExercise, required this.unitSystem, this.defaultLoadKg});

  final WorkoutExercise workoutExercise;
  final UnitSystem unitSystem;
  final double? defaultLoadKg;
}
