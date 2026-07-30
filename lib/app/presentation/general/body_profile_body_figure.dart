import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';

extension BodyProfileBodyFigure on BodyProfile {
  // The body step is skippable, so an unstated sex still has to draw something.
  // The artwork ships two figures and the fallback is one of them rather than a
  // third neutral drawing, which would be a shape nobody's body is.
  static const VTBodyFigure figureWhenSexUnstated = VTBodyFigure.male;

  VTBodyFigure get bodyFigure => switch (sex) {
    .female => .female,
    .male => .male,
    null => figureWhenSexUnstated,
  };
}
