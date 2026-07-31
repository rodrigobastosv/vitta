import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';
import 'package:vitta/app/domain/workout/entities/workout_muscle_work.dart';
import 'package:vitta/app/presentation/general/muscle_group_body_part.dart';

extension WorkoutMuscleWorkHighlights on WorkoutMuscleWork {
  // workedMuscles is ordered hardest-first, so putIfAbsent takes the harder of the
  // two muscles that can share a shape and paints it in that muscle's region.
  List<VTBodyMapHighlight> get bodyMapHighlights {
    final highlightByPart = <VTBodyPart, VTBodyMapHighlight>{};
    for (final muscle in workedMuscles) {
      highlightByPart.putIfAbsent(
        muscle.bodyPart,
        () => VTBodyMapHighlight(part: muscle.bodyPart, color: muscle.region.color, intensity: intensityOf(muscle)),
      );
    }
    return highlightByPart.values.toList();
  }
}
