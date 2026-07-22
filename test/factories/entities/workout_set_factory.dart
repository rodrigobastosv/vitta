import 'package:vitta/app/domain/workout/entities/workout_set.dart';

abstract class WorkoutSetFactory {
  static WorkoutSet build({String id = 'set-1', int position = 0, int reps = 10, double weightKg = 40}) =>
      WorkoutSet(id: id, position: position, reps: reps, weightKg: weightKg);

  static WorkoutSet cardio({String id = 'set-1', int position = 0, int durationSeconds = 1500, double? distanceMeters = 5000}) =>
      WorkoutSet(id: id, position: position, durationSeconds: durationSeconds, distanceMeters: distanceMeters);
}
