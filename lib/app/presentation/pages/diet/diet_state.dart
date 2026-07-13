import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class DietState extends Equatable {
  const DietState({required this.date, required this.dailyMacros, required this.macroGoals, this.loggedDatesInMonth = const {}});

  final DateTime date;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;
  final Set<DateTime> loggedDatesInMonth;

  DietState copyWith({DateTime? date, DailyMacros? dailyMacros, MacroGoals? macroGoals, Set<DateTime>? loggedDatesInMonth}) => DietState(
    date: date ?? this.date,
    dailyMacros: dailyMacros ?? this.dailyMacros,
    macroGoals: macroGoals ?? this.macroGoals,
    loggedDatesInMonth: loggedDatesInMonth ?? this.loggedDatesInMonth,
  );

  @override
  List<Object?> get props => [date, dailyMacros, macroGoals, loggedDatesInMonth];
}
