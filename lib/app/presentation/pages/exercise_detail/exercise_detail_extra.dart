import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';

class ExerciseDetailExtra {
  const ExerciseDetailExtra({required this.exercise, required this.bodyFigure});

  final Exercise exercise;
  final VTBodyFigure bodyFigure;
}
