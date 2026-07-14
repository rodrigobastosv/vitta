import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class DietDayExtra {
  const DietDayExtra({required this.date, required this.dailyMacros, required this.macroGoals});

  final DateTime date;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;
}
