import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class DietHistoryState extends Equatable {
  const DietHistoryState({
    required this.month,
    required this.macroGoals,
    this.macrosInMonth = const {},
    this.trendRange = TrendRange.month,
    this.macrosInTrendRange = const {},
  });

  final DateTime month;
  final MacroGoals macroGoals;
  final Map<DateTime, DailyMacros> macrosInMonth;
  final TrendRange trendRange;
  final Map<DateTime, DailyMacros> macrosInTrendRange;

  bool get hasData => macrosInMonth.isNotEmpty || macrosInTrendRange.isNotEmpty;

  DietHistoryState copyWith({
    DateTime? month,
    MacroGoals? macroGoals,
    Map<DateTime, DailyMacros>? macrosInMonth,
    TrendRange? trendRange,
    Map<DateTime, DailyMacros>? macrosInTrendRange,
  }) => DietHistoryState(
    month: month ?? this.month,
    macroGoals: macroGoals ?? this.macroGoals,
    macrosInMonth: macrosInMonth ?? this.macrosInMonth,
    trendRange: trendRange ?? this.trendRange,
    macrosInTrendRange: macrosInTrendRange ?? this.macrosInTrendRange,
  );

  @override
  List<Object?> get props => [month, macroGoals, macrosInMonth, trendRange, macrosInTrendRange];
}
