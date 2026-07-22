import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class WorkoutExercise extends Equatable with WorkoutVolume {
  const WorkoutExercise({required this.id, required this.exercise, required this.position, required this.sets, this.completedAt});

  factory WorkoutExercise.fromMap(Map<String, dynamic> row) => WorkoutExercise(
    id: row['id'] as String,
    exercise: Exercise.fromMap(row['exercises'] as Map<String, dynamic>),
    position: (row['position'] as num).toInt(),
    sets: _setsFromRow(row['workout_sets']),
    completedAt: switch (row['completed_at']) {
      final String value => DateTime.parse(value).toLocal(),
      _ => null,
    },
  );

  static List<WorkoutSet> _setsFromRow(dynamic raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }
    final sets = raw.cast<Map<String, dynamic>>().map(WorkoutSet.fromMap).toList()..sort((a, b) => a.position.compareTo(b.position));
    return sets;
  }

  final String id;
  final Exercise exercise;
  final int position;

  @override
  final List<WorkoutSet> sets;

  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  // A cardio exercise is logged once, as a single effort - a treadmill run is not
  // four sets of anything (issue #212). Which is why it is asked of the exercise
  // rather than recorded per set: nothing about the row says "this is the only one".
  bool get isCardio => exercise.category.isCardio;

  // Logging is offered until the effort exists; after that the row is edited.
  bool get canLogSet => !isCardio || sets.isEmpty;

  @override
  List<Object?> get props => [id, exercise, position, sets, completedAt];
}
