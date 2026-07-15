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

  /// When the user marked this done. Null while it's still in progress -
  /// never derived from having sets, which is a different fact (see the
  /// column comment in schema.sql).
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [id, exercise, position, sets, completedAt];
}
