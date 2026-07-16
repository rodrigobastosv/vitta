import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

class Workout extends Equatable with WorkoutVolume {
  const Workout({required this.id, required this.performedDate, required this.exercises, this.notes, this.routineId});

  factory Workout.fromMap(Map<String, dynamic> row) => Workout(
    id: row['id'] as String,
    performedDate: DateTime.parse(row['performed_date'] as String),
    notes: row['notes'] as String?,
    routineId: row['routine_id'] as String?,
    exercises: _exercisesFromRow(row['workout_exercises']),
  );

  static List<WorkoutExercise> _exercisesFromRow(dynamic raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }
    final exercises = raw.cast<Map<String, dynamic>>().map(WorkoutExercise.fromMap).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return exercises;
  }

  final String id;
  final DateTime performedDate;
  final List<WorkoutExercise> exercises;
  final String? notes;

  final String? routineId;

  @override
  List<WorkoutSet> get sets => [for (final exercise in exercises) ...exercise.sets];

  bool get isComplete => exercises.isNotEmpty && exercises.every((exercise) => exercise.isCompleted);

  Set<BodyRegion> get regions => {
    for (final exercise in exercises)
      for (final muscle in exercise.exercise.primaryMuscles) muscle.region,
  };

  @override
  List<Object?> get props => [id, performedDate, exercises, notes, routineId];
}
