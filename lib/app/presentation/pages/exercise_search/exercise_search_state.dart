import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class ExerciseSearchState extends Equatable {
  const ExerciseSearchState({this.query = '', this.results, this.muscleGroup});

  final String query;

  /// Null means no search has run yet (the idle prompt); a non-null empty list
  /// means a search ran and matched nothing - two different states sharing one
  /// field, the same shape `FoodSearchState.results` uses.
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
