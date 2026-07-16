import 'package:equatable/equatable.dart';

class WorkoutSet extends Equatable {
  const WorkoutSet({required this.id, required this.position, required this.reps, required this.weightKg});

  factory WorkoutSet.fromMap(Map<String, dynamic> row) => WorkoutSet(
    id: row['id'] as String,
    position: (row['position'] as num).toInt(),
    reps: (row['reps'] as num).toInt(),
    weightKg: (row['weight_kg'] as num).toDouble(),
  );

  final String id;
  final int position;
  final int reps;
  final double weightKg;

  double get volumeKg => reps * weightKg;

  double get estimatedOneRepMax => weightKg * (1 + reps / 30);

  bool get isBodyweight => weightKg == 0;

  @override
  List<Object?> get props => [id, position, reps, weightKg];
}
