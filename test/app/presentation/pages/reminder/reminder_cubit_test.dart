import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_completion.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_filter.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_presentation_event.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/reminder_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

MockNotificationService _permissiveNotifications() {
  final notifications = MockNotificationService();
  when(notifications.requestPermission).thenAnswer((_) async => true);
  when(
    () => notifications.scheduleReminder(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      dateTime: any(named: 'dateTime'),
    ),
  ).thenAnswer((_) async {});
  when(() => notifications.cancel(any())).thenAnswer((_) async {});
  return notifications;
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(ReminderRecurrence.none);
    registerFallbackValue(ReminderFactory.build());
  });

  final today = DateTime(2026, 7, 18);

  blocTest<ReminderCubit, ReminderState>(
    'loadDate emits the reminders for the date',
    build: () {
      final getReminders = MockGetRemindersForDateUseCase();
      when(() => getReminders(date: any(named: 'date'))).thenAnswer((_) async => Success([ReminderFactory.build()]));
      return CubitsFactories.buildReminderCubit(getRemindersForDateUseCase: getReminders);
    },
    act: (cubit) => cubit.loadDate(today),
    expect: () => [isA<ReminderState>().having((state) => state.reminders.length, 'reminders', 1)],
  );

  blocPresentationTest<ReminderCubit, ReminderState, ReminderPresentationEvent>(
    'the first load shows no overlay - the skeleton covers it',
    build: () {
      final getReminders = MockGetRemindersForDateUseCase();
      when(() => getReminders(date: any(named: 'date'))).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildReminderCubit(getRemindersForDateUseCase: getReminders);
    },
    act: (cubit) => cubit.loadDate(today),
    expectPresentation: () => <ReminderPresentationEvent>[],
  );

  blocTest<ReminderCubit, ReminderState>(
    'changeFilter narrows the visible reminders without re-querying',
    build: CubitsFactories.buildReminderCubit,
    seed: () => ReminderState(
      date: today,
      reminders: [
        ReminderFactory.build(id: 'a'),
        ReminderFactory.build(id: 'b', completedAt: DateTime(2026, 7, 18, 9)),
      ],
      filter: .all,
    ),
    act: (cubit) => cubit.changeFilter(ReminderFilter.completed),
    expect: () => [
      isA<ReminderState>().having((state) => state.filter, 'filter', ReminderFilter.completed).having((state) => state.visibleReminders.length, 'visible', 1),
    ],
  );

  blocTest<ReminderCubit, ReminderState>(
    'createReminder appends the saved reminder when it lands on the shown day',
    build: () {
      useMockLog();
      final createReminder = MockCreateReminderUseCase();
      when(
        () => createReminder(
          title: any(named: 'title'),
          dueDate: any(named: 'dueDate'),
          notes: any(named: 'notes'),
          remindAt: any(named: 'remindAt'),
          recurrence: any(named: 'recurrence'),
        ),
      ).thenAnswer((_) async => Success(ReminderFactory.build(id: 'new', dueDate: today)));
      return CubitsFactories.buildReminderCubit(createReminderUseCase: createReminder, notificationService: _permissiveNotifications());
    },
    seed: () => ReminderState(date: today, reminders: const [], filter: .all),
    act: (cubit) => cubit.createReminder(title: 'Pay rent', dueDate: today),
    expect: () => [isA<ReminderState>().having((state) => state.reminders.single.id, 'saved id', 'new')],
  );

  blocTest<ReminderCubit, ReminderState>(
    'setCompleted ticks the reminder and adds the spawned next occurrence',
    build: () {
      useMockLog();
      final complete = MockCompleteReminderUseCase();
      final completed = ReminderFactory.build(id: 'a', completedAt: DateTime(2026, 7, 18, 10));
      final spawned = ReminderFactory.build(id: 'a-next', dueDate: today);
      when(
        () => complete(reminder: any(named: 'reminder'), completed: true),
      ).thenAnswer((_) async => Success(ReminderCompletion(reminder: completed, nextOccurrence: spawned)));
      return CubitsFactories.buildReminderCubit(completeReminderUseCase: complete, notificationService: _permissiveNotifications());
    },
    seed: () => ReminderState(
      date: today,
      reminders: [ReminderFactory.build(id: 'a', recurrence: .monthly)],
      filter: .all,
    ),
    act: (cubit) => cubit.setCompleted(
      reminder: ReminderFactory.build(id: 'a', recurrence: .monthly),
      completed: true,
    ),
    expect: () => [
      // optimistic tick
      isA<ReminderState>().having((state) => state.reminders.first.isCompleted, 'optimistic completed', true),
      // server value + spawned occurrence
      isA<ReminderState>()
          .having((state) => state.reminders.length, 'count with spawned', 2)
          .having((state) => state.reminders.any((reminder) => reminder.id == 'a-next'), 'has next', true),
    ],
  );

  blocTest<ReminderCubit, ReminderState>(
    'deleteReminder removes it optimistically and reverts on failure',
    build: () {
      final delete = MockDeleteReminderUseCase();
      when(() => delete(reminderId: 'a')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildReminderCubit(deleteReminderUseCase: delete, notificationService: _permissiveNotifications());
    },
    seed: () => ReminderState(
      date: today,
      reminders: [ReminderFactory.build(id: 'a')],
      filter: .all,
    ),
    act: (cubit) => cubit.deleteReminder(reminder: ReminderFactory.build(id: 'a')),
    expect: () => [
      isA<ReminderState>().having((state) => state.reminders, 'removed', isEmpty),
      isA<ReminderState>().having((state) => state.reminders.length, 'reverted', 1),
    ],
  );
}
