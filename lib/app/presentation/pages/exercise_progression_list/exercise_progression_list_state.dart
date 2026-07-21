import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';

class ExerciseProgressionListState extends Equatable {
  const ExerciseProgressionListState({this.exercises = const []});

  final List<Exercise> exercises;

  ExerciseProgressionListState copyWith({List<Exercise>? exercises}) => ExerciseProgressionListState(exercises: exercises ?? this.exercises);

  @override
  List<Object?> get props => [exercises];
}
