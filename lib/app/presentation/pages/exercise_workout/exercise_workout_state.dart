import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

class ExerciseWorkoutState extends Equatable {
  const ExerciseWorkoutState({required this.workoutExercise});

  final WorkoutExercise workoutExercise;

  bool get isCompleted => workoutExercise.completedAt != null;

  bool get canComplete => workoutExercise.sets.isNotEmpty;

  ExerciseWorkoutState copyWith({WorkoutExercise? workoutExercise}) => ExerciseWorkoutState(workoutExercise: workoutExercise ?? this.workoutExercise);

  @override
  List<Object?> get props => [workoutExercise];
}
