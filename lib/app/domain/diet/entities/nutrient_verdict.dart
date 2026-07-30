import 'package:vitta/app/core/goals/goal_adherence.dart';

// Whether a nutrient landed under, inside or over its goal band. It reads off
// the same GoalAdherence bounds the calendar and the calorie ring use, so a
// nutrient can never be called "on track" by one surface and off by another.
enum NutrientVerdict {
  low,
  onTrack,
  high;

  static NutrientVerdict forRatio(double consumedToGoalRatio) {
    if (consumedToGoalRatio < GoalAdherence.metLowerBound) {
      return .low;
    }
    return consumedToGoalRatio > GoalAdherence.metUpperBound ? .high : .onTrack;
  }
}
