import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

/// A 1-5 night rating on the same red/amber/green scale GoalAdherence uses, so
/// "worse is redder" reads the same everywhere in the app.
Color sleepQualityColor(int rating) => switch (rating) {
  >= 5 => VTColors.green,
  4 => VTColors.success,
  3 => VTColors.warning,
  _ => VTColors.error,
};
