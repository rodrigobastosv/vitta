import 'package:vitta/app/core/goals/goal_adherence.dart';

enum TrendsVerdict {
  onTrack,
  mixed,
  offTrack;

  static const mixedLowerBound = 0.5;

  static TrendsVerdict forOnTrackRatio(double onTrackRatio) {
    if (onTrackRatio >= 1) {
      return .onTrack;
    }
    if (onTrackRatio >= mixedLowerBound) {
      return .mixed;
    }
    return .offTrack;
  }

  GoalAdherence get adherence => switch (this) {
    .onTrack => .met,
    .mixed => .close,
    .offTrack => .off,
  };
}
