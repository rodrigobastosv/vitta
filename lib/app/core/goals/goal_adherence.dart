import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

enum GoalAdherence {
  met,
  close,
  off;

  Color get color => switch (this) {
    .met => VTColors.green,
    .close => VTColors.warning,
    .off => VTColors.error,
  };

  /// The band around a goal that counts as "on target" (green). Public because
  /// the calorie goal shows this as its min/max range (issue #116), so the
  /// range on the goals page means exactly what "met" means everywhere else.
  static const metLowerBound = 0.9;
  static const metUpperBound = 1.1;
  static const _closeLowerBound = 0.75;
  static const _closeUpperBound = 1.25;

  static GoalAdherence forRatio(double consumedToGoalRatio) {
    if (consumedToGoalRatio >= metLowerBound && consumedToGoalRatio <= metUpperBound) {
      return .met;
    }
    if (consumedToGoalRatio >= _closeLowerBound && consumedToGoalRatio <= _closeUpperBound) {
      return .close;
    }
    return .off;
  }

  GoalAdherence combineWorst(GoalAdherence other) => index >= other.index ? this : other;
}
