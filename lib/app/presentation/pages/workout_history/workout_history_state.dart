import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState({
    required this.month,
    this.workoutsInMonth = const {},
    this.workoutsInTrendRange = const {},
    this.trendRange = TrendRange.month,
  });

  final DateTime month;
  final Map<DateTime, DailyWorkout> workoutsInMonth;
  final Map<DateTime, DailyWorkout> workoutsInTrendRange;
  final TrendRange trendRange;

  WorkoutHistoryState copyWith({
    DateTime? month,
    Map<DateTime, DailyWorkout>? workoutsInMonth,
    Map<DateTime, DailyWorkout>? workoutsInTrendRange,
    TrendRange? trendRange,
  }) => WorkoutHistoryState(
    month: month ?? this.month,
    workoutsInMonth: workoutsInMonth ?? this.workoutsInMonth,
    workoutsInTrendRange: workoutsInTrendRange ?? this.workoutsInTrendRange,
    trendRange: trendRange ?? this.trendRange,
  );

  @override
  List<Object?> get props => [month, workoutsInMonth, workoutsInTrendRange, trendRange];
}
