import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/set_kind.dart';

class WorkoutSet extends Equatable {
  const WorkoutSet({
    required this.id,
    required this.position,
    this.reps,
    this.weightKg = 0,
    this.durationSeconds,
    this.distanceMeters,
  });

  factory WorkoutSet.fromMap(Map<String, dynamic> row) => WorkoutSet(
    id: row['id'] as String,
    position: (row['position'] as num).toInt(),
    reps: (row['reps'] as num?)?.toInt(),
    weightKg: (row['weight_kg'] as num?)?.toDouble() ?? 0,
    durationSeconds: (row['duration_seconds'] as num?)?.toInt(),
    distanceMeters: (row['distance_meters'] as num?)?.toDouble(),
  );

  final String id;
  final int position;
  final int? reps;
  final double weightKg;
  final int? durationSeconds;
  final double? distanceMeters;

  SetKind get kind => durationSeconds != null ? SetKind.cardio : SetKind.strength;

  bool get isCardio => kind == SetKind.cardio;

  double get volumeKg => (reps ?? 0) * weightKg;

  double get estimatedOneRepMax => weightKg * (1 + (reps ?? 0) / 30);

  bool get isBodyweight => kind == SetKind.strength && weightKg == 0;

  @override
  List<Object?> get props => [id, position, reps, weightKg, durationSeconds, distanceMeters];
}
