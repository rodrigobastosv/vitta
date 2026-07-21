import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  MockGetSleepGoalUseCase stubbedGoal([double goalHours = 8]) {
    final getSleepGoalUseCase = MockGetSleepGoalUseCase();
    when(getSleepGoalUseCase.call).thenReturn(goalHours);
    return getSleepGoalUseCase;
  }

  MockGetSleepInRangeUseCase stubbedRange(Map<DateTime, DailySleep> sleepByDate) {
    final getSleepInRangeUseCase = MockGetSleepInRangeUseCase();
    when(
      () => getSleepInRangeUseCase(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => Success(sleepByDate));
    return getSleepInRangeUseCase;
  }

  test('starts on the current month with the default goal until the real one loads', () {
    final cubit = CubitsFactories.buildSleepHistoryCubit();
    final now = DateTime.now();

    expect(cubit.state.month, DateTime(now.year, now.month));
    expect(cubit.state.durationGoalHours, 8);
    expect(cubit.state.trendRange, TrendRange.month);
  });

  test('refresh picks up the saved goal and queries the month and trend separately', () async {
    final getSleepInRangeUseCase = stubbedRange({});
    final cubit = CubitsFactories.buildSleepHistoryCubit(getSleepInRangeUseCase: getSleepInRangeUseCase, getSleepGoalUseCase: stubbedGoal(7.5));

    await cubit.refresh();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(cubit.state.durationGoalHours, 7.5);
    verify(() => getSleepInRangeUseCase(from: DateTime(now.year, now.month), to: DateTime(now.year, now.month + 1, 0))).called(1);
    verify(() => getSleepInRangeUseCase(from: today.subtract(const Duration(days: 29)), to: today)).called(1);
  });

  blocTest<SleepHistoryCubit, SleepHistoryState>(
    'going to the previous month emits the new month immediately, then its nights',
    build: () => CubitsFactories.buildSleepHistoryCubit(
      getSleepInRangeUseCase: stubbedRange({
        DateTime(2026, 6, 10): DailySleep(
          entries: [SleepLog(id: 'a', loggedDate: DateTime(2026, 6, 10), bedTime: DateTime(2026, 6, 10, 23), wakeTime: DateTime(2026, 6, 11, 7))],
        ),
      }),
      getSleepGoalUseCase: stubbedGoal(),
    ),
    act: (cubit) => cubit.goToPreviousMonth(),
    expect: () => [
      isA<SleepHistoryState>().having((state) => state.sleepInMonth, 'sleepInMonth', isEmpty),
      isA<SleepHistoryState>().having((state) => state.sleepInMonth, 'sleepInMonth', isNotEmpty),
    ],
  );

  blocPresentationTest<SleepHistoryCubit, SleepHistoryState, SleepHistoryPresentationEvent>(
    'emits SleepHistoryError when a range query fails',
    build: () {
      final getSleepInRangeUseCase = MockGetSleepInRangeUseCase();
      when(
        () => getSleepInRangeUseCase(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildSleepHistoryCubit(getSleepInRangeUseCase: getSleepInRangeUseCase, getSleepGoalUseCase: stubbedGoal());
    },
    act: (cubit) => cubit.changeTrendRange(TrendRange.week),
    expectPresentation: () => [
      isA<SleepHistoryShowLoading>(),
      isA<SleepHistoryError>().having((event) => event.message, 'message', 'boom'),
      isA<SleepHistoryHideLoading>(),
    ],
  );
}
