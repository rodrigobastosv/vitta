import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class ExerciseSearchState extends Equatable {
  const ExerciseSearchState({this.query = '', this.results, this.muscleGroup, this.category});

  final String query;

  final List<Exercise>? results;
  final MuscleGroup? muscleGroup;
  final ExerciseCategory? category;

  ExerciseSearchState copyWith({
    String? query,
    List<Exercise>? results,
    MuscleGroup? muscleGroup,
    bool clearMuscleGroup = false,
    ExerciseCategory? category,
    bool clearCategory = false,
  }) => ExerciseSearchState(
    query: query ?? this.query,
    results: results ?? this.results,
    muscleGroup: clearMuscleGroup ? null : muscleGroup ?? this.muscleGroup,
    category: clearCategory ? null : category ?? this.category,
  );

  @override
  List<Object?> get props => [query, results, muscleGroup, category];
}
