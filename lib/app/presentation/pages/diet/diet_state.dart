import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class DietState extends Equatable {
  const DietState({required this.date, required this.dailyMacros, required this.macroGoals, this.loggedMacrosInMonth = const {}});

  final DateTime date;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;
  final Map<DateTime, DailyMacros> loggedMacrosInMonth;

  DietState copyWith({DateTime? date, DailyMacros? dailyMacros, MacroGoals? macroGoals, Map<DateTime, DailyMacros>? loggedMacrosInMonth}) =>
      DietState(
        date: date ?? this.date,
        dailyMacros: dailyMacros ?? this.dailyMacros,
        macroGoals: macroGoals ?? this.macroGoals,
        loggedMacrosInMonth: loggedMacrosInMonth ?? this.loggedMacrosInMonth,
      );

  @override
  List<Object?> get props => [date, dailyMacros, macroGoals, loggedMacrosInMonth];
}
