import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class SleepHistoryState extends Equatable {
  const SleepHistoryState({
    required this.month,
    required this.durationGoalHours,
    this.sleepInMonth = const {},
    this.sleepInTrendRange = const {},
    this.trendRange = TrendRange.month,
    this.isLoaded = false,
  });

  final DateTime month;
  final double durationGoalHours;
  final Map<DateTime, DailySleep> sleepInMonth;
  final Map<DateTime, DailySleep> sleepInTrendRange;
  final TrendRange trendRange;

  final bool isLoaded;

  bool get hasData => sleepInMonth.isNotEmpty || sleepInTrendRange.isNotEmpty;

  SleepHistoryState copyWith({
    bool? isLoaded,
    DateTime? month,
    double? durationGoalHours,
    Map<DateTime, DailySleep>? sleepInMonth,
    Map<DateTime, DailySleep>? sleepInTrendRange,
    TrendRange? trendRange,
  }) => SleepHistoryState(
    isLoaded: isLoaded ?? this.isLoaded,
    month: month ?? this.month,
    durationGoalHours: durationGoalHours ?? this.durationGoalHours,
    sleepInMonth: sleepInMonth ?? this.sleepInMonth,
    sleepInTrendRange: sleepInTrendRange ?? this.sleepInTrendRange,
    trendRange: trendRange ?? this.trendRange,
  );

  @override
  List<Object?> get props => [isLoaded, month, durationGoalHours, sleepInMonth, sleepInTrendRange, trendRange];
}
