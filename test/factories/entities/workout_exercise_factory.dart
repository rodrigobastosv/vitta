import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

import 'exercise_factory.dart';

abstract class WorkoutExerciseFactory {
  static WorkoutExercise build({
    String id = 'workout-exercise-1',
    Exercise? exercise,
    int position = 0,
    List<WorkoutSet> sets = const [],
    DateTime? completedAt,
  }) => WorkoutExercise(id: id, exercise: exercise ?? ExerciseFactory.build(), position: position, sets: sets, completedAt: completedAt);
}
