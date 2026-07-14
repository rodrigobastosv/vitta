import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

class CalorieAverage extends Equatable {
  const CalorieAverage({required this.loggedDayCount, required this.averageCalories});

  factory CalorieAverage.fromLoggedDays(List<DailyMacros> loggedDays) {
    final daysWithFood = loggedDays.where((day) => day.entries.isNotEmpty).toList();
    if (daysWithFood.isEmpty) {
      return const CalorieAverage(loggedDayCount: 0, averageCalories: 0);
    }
    final totalCalories = daysWithFood.fold<double>(0, (sum, day) => sum + day.totalCalories);
    return CalorieAverage(loggedDayCount: daysWithFood.length, averageCalories: totalCalories / daysWithFood.length);
  }

  final int loggedDayCount;
  final double averageCalories;

  bool get hasData => loggedDayCount > 0;

  @override
  List<Object?> get props => [loggedDayCount, averageCalories];
}
