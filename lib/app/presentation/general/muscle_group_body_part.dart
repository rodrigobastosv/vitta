import 'package:vitta/app/design_system/components/general/vt_body_part.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

extension MuscleGroupBodyPart on MuscleGroup {
  VTBodyPart get bodyPart => switch (this) {
    .abdominals => .abdominals,
    .abductors => .abductors,
    .adductors => .adductors,
    .biceps => .biceps,
    .calves => .calves,
    .chest => .chest,
    .forearms => .forearms,
    .glutes => .glutes,
    .hamstrings => .hamstrings,
    .lats => .lats,
    .lowerBack => .lowerBack,
    .middleBack => .middleBack,
    .neck => .neck,
    .quadriceps => .quadriceps,
    .shoulders => .shoulders,
    .traps => .traps,
    .triceps => .triceps,
  };
}
