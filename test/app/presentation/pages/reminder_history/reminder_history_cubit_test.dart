import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/reminder_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  final today = DateTime(2026, 7, 18);

  blocTest<ReminderHistoryCubit, ReminderHistoryState>(
    'loadMonth groups reminders by their day',
    build: () {
      final getRange = MockGetRemindersInRangeUseCase();
      when(
        () => getRange(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer(
        (_) async => Success({
          today: [ReminderFactory.build(id: 'a'), ReminderFactory.build(id: 'b')],
        }),
      );
      return CubitsFactories.buildReminderHistoryCubit(getRemindersInRangeUseCase: getRange);
    },
    act: (cubit) => cubit.loadMonth(DateTime(2026, 7)),
    expect: () => [isA<ReminderHistoryState>().having((state) => state.remindersInMonth[today]?.length, 'day count', 2)],
  );

  blocTest<ReminderHistoryCubit, ReminderHistoryState>(
    'selectDay exposes that day reminders and goToNextMonth clears the selection',
    build: () {
      final getRange = MockGetRemindersInRangeUseCase();
      when(
        () => getRange(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => const Success({}));
      return CubitsFactories.buildReminderHistoryCubit(getRemindersInRangeUseCase: getRange);
    },
    seed: () => ReminderHistoryState(
      month: DateTime(2026, 7),
      remindersInMonth: {
        today: [ReminderFactory.build()],
      },
    ),
    act: (cubit) async {
      cubit.selectDay(today);
      await cubit.goToNextMonth();
    },
    expect: () => [
      isA<ReminderHistoryState>().having((state) => state.selectedReminders.length, 'selected reminders', 1),
      isA<ReminderHistoryState>()
          .having((state) => state.selectedDay, 'cleared on month change', isNull)
          .having((state) => state.month, 'reloaded month', DateTime(2026, 8)),
    ],
  );

  blocTest<ReminderHistoryCubit, ReminderHistoryState>(
    'goToNextMonth advances the month and reloads',
    build: () {
      final getRange = MockGetRemindersInRangeUseCase();
      when(
        () => getRange(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => const Success({}));
      return CubitsFactories.buildReminderHistoryCubit(getRemindersInRangeUseCase: getRange);
    },
    seed: () => ReminderHistoryState(month: DateTime(2026, 7)),
    act: (cubit) => cubit.goToNextMonth(),
    expect: () => [isA<ReminderHistoryState>().having((state) => state.month, 'month', DateTime(2026, 8))],
  );
}
