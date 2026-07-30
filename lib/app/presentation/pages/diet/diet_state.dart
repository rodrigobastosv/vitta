import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/logging_streak.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class DietState extends Equatable {
  const DietState({
    required this.date,
    required this.dailyMacros,
    required this.macroGoals,
    this.macrosByDate = const {},
    this.streak = LoggingStreak.none,
    this.isLoaded = true,
  });

  final DateTime date;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;

  // Accumulates across every range that has been read, so the week strip, the
  // streak window and whichever month the calendar sheet is browsing all draw
  // from one map and paging back to a month already seen costs no second query.
  // The CopyMealsState.macrosByDate shape.
  final Map<DateTime, DailyMacros> macrosByDate;

  final LoggingStreak streak;
  final bool isLoaded;

  DietState copyWith({
    DateTime? date,
    DailyMacros? dailyMacros,
    MacroGoals? macroGoals,
    Map<DateTime, DailyMacros>? macrosByDate,
    LoggingStreak? streak,
    bool? isLoaded,
  }) => DietState(
    isLoaded: isLoaded ?? this.isLoaded,
    date: date ?? this.date,
    dailyMacros: dailyMacros ?? this.dailyMacros,
    macroGoals: macroGoals ?? this.macroGoals,
    macrosByDate: macrosByDate ?? this.macrosByDate,
    streak: streak ?? this.streak,
  );

  @override
  List<Object?> get props => [isLoaded, date, dailyMacros, macroGoals, macrosByDate, streak];
}
