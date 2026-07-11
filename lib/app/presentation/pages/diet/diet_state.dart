import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

sealed class DietState extends Equatable {
  const DietState();

  @override
  List<Object?> get props => [];
}

class DietLoading extends DietState {
  const DietLoading();
}

class DietLoaded extends DietState {
  const DietLoaded({required this.date, required this.dailyMacros});

  final DateTime date;
  final DailyMacros dailyMacros;

  @override
  List<Object?> get props => [date, dailyMacros];
}

class DietError extends DietState {
  const DietError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
