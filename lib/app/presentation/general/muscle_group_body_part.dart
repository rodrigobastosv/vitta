import 'package:vitta/app/design_system/components/general/vt_body_part.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

// Two muscles share a shape with a neighbour, because the artwork is drawn at the
// granularity a body map can actually show: the lats and the rhomboids are one
// upper back, and the hip abductors are the outer half of the glutes. Whichever
// of the pair was worked harder is what tints it - see WorkoutBodyMapCard.
extension MuscleGroupBodyPart on MuscleGroup {
  VTBodyPart get bodyPart => switch (this) {
    .abdominals => .abs,
    .abductors => .gluteal,
    .adductors => .adductors,
    .biceps => .biceps,
    .calves => .calves,
    .chest => .chest,
    .forearms => .forearm,
    .glutes => .gluteal,
    .hamstrings => .hamstring,
    .lats => .upperBack,
    .lowerBack => .lowerBack,
    .middleBack => .upperBack,
    .neck => .neck,
    .quadriceps => .quadriceps,
    .shoulders => .deltoids,
    .traps => .trapezius,
    .triceps => .triceps,
  };
}
