import 'package:vitta/app/domain/reminder/entities/reminder.dart';

class ReminderDayExtra {
  const ReminderDayExtra({required this.date, required this.reminders});

  final DateTime date;
  final List<Reminder> reminders;
}
