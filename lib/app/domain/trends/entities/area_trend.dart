import 'package:equatable/equatable.dart';
import 'package:vitta/app/core/goals/daily_goal_average.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/domain/trends/entities/trend_direction.dart';

class AreaTrend extends Equatable {
  const AreaTrend({this.days = const [], this.valuesByDate = const {}, this.previousValuesByDate = const {}, this.goal});

  final List<DateTime> days;
  final Map<DateTime, double> valuesByDate;
  final Map<DateTime, double> previousValuesByDate;
  final double? goal;

  DailyGoalAverage get current => DailyGoalAverage.fromValues(valuesByDate.values);

  DailyGoalAverage get previous => DailyGoalAverage.fromValues(previousValuesByDate.values);

  bool get hasData => current.hasData;

  double? get changeRatio {
    if (!hasData || !previous.hasData || previous.average <= 0) {
      return null;
    }
    return current.average / previous.average;
  }

  TrendDirection? get direction => switch (changeRatio) {
    final changeRatio? => TrendDirection.forChangeRatio(changeRatio),
    null => null,
  };

  GoalAdherence? get adherence {
    if (!hasData) {
      return null;
    }
    return switch (goal) {
      final goal? when goal > 0 => GoalAdherence.forRatio(current.average / goal),
      _ => null,
    };
  }

  bool get isOnTrack => adherence == GoalAdherence.met;

  bool get isJudged => adherence != null;

  @override
  List<Object?> get props => [days, valuesByDate, previousValuesByDate, goal];
}
