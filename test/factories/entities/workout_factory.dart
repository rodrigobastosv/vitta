import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

abstract class WorkoutFactory {
  static Workout build({String id = 'workout-1', DateTime? performedDate, List<WorkoutExercise> exercises = const [], String? notes}) =>
      Workout(id: id, performedDate: performedDate ?? DateTime(2026, 7, 15), exercises: exercises, notes: notes);
}
