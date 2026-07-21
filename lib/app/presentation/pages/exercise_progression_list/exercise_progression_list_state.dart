import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';

class ExerciseProgressionListState extends Equatable {
  const ExerciseProgressionListState({this.exercises = const [], this.isLoaded = true});

  final List<Exercise> exercises;
  final bool isLoaded;

  ExerciseProgressionListState copyWith({List<Exercise>? exercises, bool? isLoaded}) =>
      ExerciseProgressionListState(isLoaded: isLoaded ?? this.isLoaded, exercises: exercises ?? this.exercises);

  @override
  List<Object?> get props => [isLoaded, exercises];
}
