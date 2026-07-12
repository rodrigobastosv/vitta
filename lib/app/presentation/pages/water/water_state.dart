import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

sealed class WaterState extends Equatable {
  const WaterState();

  @override
  List<Object?> get props => [];
}

class WaterLoading extends WaterState {
  const WaterLoading();
}

class WaterLoaded extends WaterState {
  const WaterLoaded({required this.date, required this.dailyWater, required this.dailyGoalMl});

  final DateTime date;
  final DailyWater dailyWater;
  final double dailyGoalMl;

  @override
  List<Object?> get props => [date, dailyWater, dailyGoalMl];
}

class WaterError extends WaterState {
  const WaterError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
