import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

class DietState extends Equatable {
  const DietState({required this.date, required this.dailyMacros});

  final DateTime date;
  final DailyMacros dailyMacros;

  DietState copyWith({DateTime? date, DailyMacros? dailyMacros}) =>
      DietState(date: date ?? this.date, dailyMacros: dailyMacros ?? this.dailyMacros);

  @override
  List<Object?> get props => [date, dailyMacros];
}
