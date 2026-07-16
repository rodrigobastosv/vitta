import 'package:equatable/equatable.dart';

class DailyGoalAverage extends Equatable {
  const DailyGoalAverage({required this.loggedDayCount, required this.average});

  factory DailyGoalAverage.fromValues(Iterable<double> valuesOfLoggedDays) {
    final values = valuesOfLoggedDays.toList();
    if (values.isEmpty) {
      return const DailyGoalAverage(loggedDayCount: 0, average: 0);
    }
    return DailyGoalAverage(loggedDayCount: values.length, average: values.reduce((a, b) => a + b) / values.length);
  }

  final int loggedDayCount;
  final double average;

  bool get hasData => loggedDayCount > 0;

  @override
  List<Object?> get props => [loggedDayCount, average];
}
