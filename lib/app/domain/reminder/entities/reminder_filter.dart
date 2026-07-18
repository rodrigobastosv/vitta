import 'package:vitta/app/domain/reminder/entities/reminder.dart';

enum ReminderFilter {
  all,
  completed,
  incomplete;

  bool matches(Reminder reminder) => switch (this) {
    .all => true,
    .completed => reminder.isCompleted,
    .incomplete => !reminder.isCompleted,
  };
}
