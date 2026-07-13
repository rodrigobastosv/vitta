import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

class WaterState extends Equatable {
  const WaterState({required this.date, required this.dailyWater, required this.dailyGoalMl});

  final DateTime date;
  final DailyWater dailyWater;
  final double dailyGoalMl;

  WaterState copyWith({DateTime? date, DailyWater? dailyWater, double? dailyGoalMl}) =>
      WaterState(date: date ?? this.date, dailyWater: dailyWater ?? this.dailyWater, dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl);

  @override
  List<Object?> get props => [date, dailyWater, dailyGoalMl];
}
