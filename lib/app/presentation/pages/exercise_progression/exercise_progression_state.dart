import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';

class ExerciseProgressionState extends Equatable {
  const ExerciseProgressionState({required this.exercise, required this.progression, this.isLoaded = true});

  final Exercise exercise;
  final ExerciseProgression progression;
  final bool isLoaded;

  ExerciseProgressionState copyWith({Exercise? exercise, ExerciseProgression? progression, bool? isLoaded}) =>
      ExerciseProgressionState(isLoaded: isLoaded ?? this.isLoaded, exercise: exercise ?? this.exercise, progression: progression ?? this.progression);

  @override
  List<Object?> get props => [isLoaded, exercise, progression];
}
