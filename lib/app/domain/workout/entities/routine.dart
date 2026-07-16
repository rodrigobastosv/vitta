import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';

class Routine extends Equatable {
  const Routine({required this.id, required this.name, required this.position, required this.exercises});

  factory Routine.fromMap(Map<String, dynamic> row) => Routine(
    id: row['id'] as String,
    name: row['name'] as String,
    position: (row['position'] as num).toInt(),
    exercises: _exercisesFromRow(row['routine_exercises']),
  );

  static List<Exercise> _exercisesFromRow(dynamic raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }
    final rows = raw.cast<Map<String, dynamic>>().toList()..sort((a, b) => (a['position'] as num).compareTo(b['position'] as num));
    return [for (final row in rows) Exercise.fromMap(row['exercises'] as Map<String, dynamic>)];
  }

  final String id;
  final String name;
  final int position;
  final List<Exercise> exercises;

  Set<BodyRegion> get regions => {
    for (final exercise in exercises)
      for (final muscle in exercise.primaryMuscles) muscle.region,
  };

  @override
  List<Object?> get props => [id, name, position, exercises];
}
