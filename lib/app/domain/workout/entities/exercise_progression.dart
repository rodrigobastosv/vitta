import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression_point.dart';

class ExerciseProgression extends Equatable {
  const ExerciseProgression({required this.points});

  final List<ExerciseProgressionPoint> points;

  bool get hasData => points.isNotEmpty;

  ExerciseProgressionPoint? get latest => points.isEmpty ? null : points.last;

  double get heaviestWeightKg => points.fold(0, (record, point) => point.heaviestWeightKg > record ? point.heaviestWeightKg : record);

  double get bestEstimatedOneRepMax =>
      points.fold(0, (record, point) => point.estimatedOneRepMax > record ? point.estimatedOneRepMax : record);

  @override
  List<Object?> get props => [points];
}
