import 'package:flutter_test/flutter_test.dart';

import '../../../../factories/entities/reminder_factory.dart';

void main() {
  final now = DateTime(2026, 7, 18, 12);

  test('a reminder past its remind time is overdue', () {
    final reminder = ReminderFactory.build(remindAt: DateTime(2026, 7, 18, 9));

    expect(reminder.isOverdue(now), isTrue);
  });

  test('a reminder whose remind time is still ahead is not overdue', () {
    final reminder = ReminderFactory.build(remindAt: DateTime(2026, 7, 18, 15));

    expect(reminder.isOverdue(now), isFalse);
  });

  test('an all-day reminder is only overdue once the whole day has passed', () {
    final today = ReminderFactory.build(dueDate: DateTime(2026, 7, 18));
    final yesterday = ReminderFactory.build(dueDate: DateTime(2026, 7, 17));

    expect(today.isOverdue(now), isFalse);
    expect(yesterday.isOverdue(now), isTrue);
  });

  test('a completed reminder is never overdue', () {
    final reminder = ReminderFactory.build(remindAt: DateTime(2026, 7, 18, 9), completedAt: DateTime(2026, 7, 18, 10));

    expect(reminder.isOverdue(now), isFalse);
  });
}
