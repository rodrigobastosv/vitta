import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class WaterHistoryState extends Equatable {
  const WaterHistoryState({
    required this.month,
    required this.dailyGoalMl,
    this.waterInMonth = const {},
    this.waterInTrendRange = const {},
    this.trendRange = TrendRange.month,
    this.isLoaded = true,
  });

  final DateTime month;
  final double dailyGoalMl;

  final Map<DateTime, DailyWater> waterInMonth;

  final Map<DateTime, DailyWater> waterInTrendRange;

  final TrendRange trendRange;

  final bool isLoaded;

  bool get hasData => waterInMonth.isNotEmpty || waterInTrendRange.isNotEmpty;

  WaterHistoryState copyWith({
    bool? isLoaded,
    DateTime? month,
    double? dailyGoalMl,
    Map<DateTime, DailyWater>? waterInMonth,
    Map<DateTime, DailyWater>? waterInTrendRange,
    TrendRange? trendRange,
  }) => WaterHistoryState(
    isLoaded: isLoaded ?? this.isLoaded,
    month: month ?? this.month,
    dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
    waterInMonth: waterInMonth ?? this.waterInMonth,
    waterInTrendRange: waterInTrendRange ?? this.waterInTrendRange,
    trendRange: trendRange ?? this.trendRange,
  );

  @override
  List<Object?> get props => [isLoaded, month, dailyGoalMl, waterInMonth, waterInTrendRange, trendRange];
}
