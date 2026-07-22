import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/reminder/reminder_repository.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

import '../../../factories/entities/reminder_factory.dart';
import '../../../mocks/datasources_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(ReminderRecurrence.none);
  });

  group('completeReminder', () {
    test('a non-recurring reminder is marked complete with no next occurrence', () async {
      final dataSource = MockSupabaseReminderDataSource();
      final reminder = ReminderFactory.build();
      final completed = ReminderFactory.build(completedAt: DateTime(2026, 7, 18, 10));
      when(
        () => dataSource.setCompleted(
          reminderId: 'reminder-1',
          completedAt: any(named: 'completedAt'),
        ),
      ).thenAnswer((_) async => Success(completed));

      final result = await ReminderRepository(supabaseReminderDataSource: dataSource).completeReminder(reminder: reminder, completed: true);

      final completion = result.when((_) => null, (value) => value);
      expect(completion?.reminder, isNotNull);
      expect(completion?.nextOccurrence, isNull);
      verifyNever(
        () => dataSource.createReminder(
          title: any(named: 'title'),
          dueDate: any(named: 'dueDate'),
          notes: any(named: 'notes'),
          remindAt: any(named: 'remindAt'),
          recurrence: any(named: 'recurrence'),
        ),
      );
    });

    test('completing a monthly reminder spawns the next month occurrence', () async {
      final dataSource = MockSupabaseReminderDataSource();
      final reminder = ReminderFactory.build(dueDate: DateTime(2026, 7, 18), remindAt: DateTime(2026, 7, 18, 9), recurrence: .monthly);
      when(
        () => dataSource.setCompleted(
          reminderId: 'reminder-1',
          completedAt: any(named: 'completedAt'),
        ),
      ).thenAnswer((_) async => Success(ReminderFactory.build(completedAt: DateTime(2026, 7, 18, 10))));
      final spawned = ReminderFactory.build(id: 'reminder-2', dueDate: DateTime(2026, 8, 18));
      when(
        () => dataSource.createReminder(
          title: any(named: 'title'),
          dueDate: any(named: 'dueDate'),
          notes: any(named: 'notes'),
          remindAt: any(named: 'remindAt'),
          recurrence: any(named: 'recurrence'),
        ),
      ).thenAnswer((_) async => Success(spawned));

      final result = await ReminderRepository(supabaseReminderDataSource: dataSource).completeReminder(reminder: reminder, completed: true);

      final completion = result.when((_) => null, (value) => value);
      expect(completion?.nextOccurrence?.id, 'reminder-2');
      final capturedDueDate = verify(
        () => dataSource.createReminder(
          title: 'Pay the electricity bill',
          dueDate: captureAny(named: 'dueDate'),
          notes: any(named: 'notes'),
          remindAt: captureAny(named: 'remindAt'),
          recurrence: .monthly,
        ),
      ).captured;
      expect(capturedDueDate.first, DateTime(2026, 8, 18));
      expect(capturedDueDate.last, DateTime(2026, 8, 18, 9));
    });

    test('un-completing a recurring reminder does not spawn an occurrence', () async {
      final dataSource = MockSupabaseReminderDataSource();
      final reminder = ReminderFactory.build(recurrence: .monthly, completedAt: DateTime(2026, 7, 18, 10));
      when(() => dataSource.setCompleted(reminderId: 'reminder-1', completedAt: null)).thenAnswer((_) async => Success(ReminderFactory.build()));

      await ReminderRepository(supabaseReminderDataSource: dataSource).completeReminder(reminder: reminder, completed: false);

      verifyNever(
        () => dataSource.createReminder(
          title: any(named: 'title'),
          dueDate: any(named: 'dueDate'),
          notes: any(named: 'notes'),
          remindAt: any(named: 'remindAt'),
          recurrence: any(named: 'recurrence'),
        ),
      );
    });

    test('a failed status update propagates the error', () async {
      final dataSource = MockSupabaseReminderDataSource();
      when(
        () => dataSource.setCompleted(
          reminderId: any(named: 'reminderId'),
          completedAt: any(named: 'completedAt'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));

      final result = await ReminderRepository(supabaseReminderDataSource: dataSource).completeReminder(reminder: ReminderFactory.build(), completed: true);

      expect(result.when((error) => error.message, (_) => null), 'boom');
    });
  });
}
