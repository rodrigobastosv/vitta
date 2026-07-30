import 'package:vitta/app/design_system/components/general/vt_body_part.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';

extension BodyRegionBodyPart on BodyRegion {
  VTBodyPart get bodyPart => switch (this) {
    .chest => .chest,
    .back => .back,
    .shoulders => .shoulders,
    .arms => .arms,
    .core => .core,
    .legs => .legs,
  };
}
