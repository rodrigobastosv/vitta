import 'package:equatable/equatable.dart';

class LogReminderSchedule extends Equatable {
  const LogReminderSchedule({required this.isEnabled, required this.minuteOfDay});

  final bool isEnabled;
  final int minuteOfDay;

  int get hour => minuteOfDay ~/ 60;

  int get minute => minuteOfDay % 60;

  LogReminderSchedule copyWith({bool? isEnabled, int? minuteOfDay}) =>
      LogReminderSchedule(isEnabled: isEnabled ?? this.isEnabled, minuteOfDay: minuteOfDay ?? this.minuteOfDay);

  DateTime nextOccurrence({required DateTime now, required bool isLoggedToday}) {
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    if (isLoggedToday || !today.isAfter(now)) {
      return DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    return today;
  }

  @override
  List<Object?> get props => [isEnabled, minuteOfDay];
}
