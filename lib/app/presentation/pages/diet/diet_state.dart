import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class DietState extends Equatable {
  const DietState({required this.date, required this.dailyMacros, required this.macroGoals});

  final DateTime date;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;

  DietState copyWith({DateTime? date, DailyMacros? dailyMacros, MacroGoals? macroGoals}) => DietState(
    date: date ?? this.date,
    dailyMacros: dailyMacros ?? this.dailyMacros,
    macroGoals: macroGoals ?? this.macroGoals,
  );

  @override
  List<Object?> get props => [date, dailyMacros, macroGoals];
}
