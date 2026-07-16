import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class ExerciseSearchState extends Equatable {
  const ExerciseSearchState({this.query = '', this.results, this.muscleGroup});

  final String query;

  final List<Exercise>? results;
  final MuscleGroup? muscleGroup;

  ExerciseSearchState copyWith({String? query, List<Exercise>? results, MuscleGroup? muscleGroup, bool clearMuscleGroup = false}) =>
      ExerciseSearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        muscleGroup: clearMuscleGroup ? null : muscleGroup ?? this.muscleGroup,
      );

  @override
  List<Object?> get props => [query, results, muscleGroup];
}
