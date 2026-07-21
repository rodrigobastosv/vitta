import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

class WaterState extends Equatable {
  const WaterState({required this.date, required this.dailyWater, required this.dailyGoalMl, this.isLoaded = true});

  final DateTime date;
  final DailyWater dailyWater;
  final double dailyGoalMl;
  final bool isLoaded;

  WaterState copyWith({DateTime? date, DailyWater? dailyWater, double? dailyGoalMl, bool? isLoaded}) => WaterState(
    isLoaded: isLoaded ?? this.isLoaded,
    date: date ?? this.date,
    dailyWater: dailyWater ?? this.dailyWater,
    dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
  );

  @override
  List<Object?> get props => [isLoaded, date, dailyWater, dailyGoalMl];
}
