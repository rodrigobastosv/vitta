import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';

class ExerciseProgressionState extends Equatable {
  const ExerciseProgressionState({required this.exercise, required this.progression});

  final Exercise exercise;
  final ExerciseProgression progression;

  ExerciseProgressionState copyWith({Exercise? exercise, ExerciseProgression? progression}) =>
      ExerciseProgressionState(exercise: exercise ?? this.exercise, progression: progression ?? this.progression);

  @override
  List<Object?> get props => [exercise, progression];
}
