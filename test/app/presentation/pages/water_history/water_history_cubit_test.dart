import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_cubit.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  MockGetWaterGoalUseCase stubbedGoal([double goalMl = 2000]) {
    final getWaterGoalUseCase = MockGetWaterGoalUseCase();
    when(getWaterGoalUseCase.call).thenReturn(goalMl);
    return getWaterGoalUseCase;
  }

  MockGetWaterInRangeUseCase stubbedRange(Map<DateTime, DailyWater> waterByDate) {
    final getWaterInRangeUseCase = MockGetWaterInRangeUseCase();
    when(
      () => getWaterInRangeUseCase(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => Success(waterByDate));
    return getWaterInRangeUseCase;
  }

  test('starts on the current month with the default 30 day trend range', () {
    final cubit = CubitsFactories.buildWaterHistoryCubit();
    final now = DateTime.now();

    expect(cubit.state.month, DateTime(now.year, now.month));
    expect(cubit.state.trendRange, TrendRange.month);
    expect(cubit.isViewingCurrentMonth, isTrue);
  });

  test('refresh queries the displayed month and the trend window separately', () async {
    final getWaterInRangeUseCase = stubbedRange({});
    final cubit = CubitsFactories.buildWaterHistoryCubit(
      getWaterInRangeUseCase: getWaterInRangeUseCase,
      getWaterGoalUseCase: stubbedGoal(2500),
    );

    await cubit.refresh();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(cubit.state.dailyGoalMl, 2500);
    verify(() => getWaterInRangeUseCase(from: DateTime(now.year, now.month), to: DateTime(now.year, now.month + 1, 0))).called(1);
    verify(() => getWaterInRangeUseCase(from: today.subtract(const Duration(days: 29)), to: today)).called(1);
  });

  test('the trend window is independent of the displayed month', () async {
    final getWaterInRangeUseCase = stubbedRange({});
    final cubit = CubitsFactories.buildWaterHistoryCubit(
      getWaterInRangeUseCase: getWaterInRangeUseCase,
      getWaterGoalUseCase: stubbedGoal(),
    );

    await cubit.changeTrendRange(TrendRange.week);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(cubit.trendDays, hasLength(7));
    expect(cubit.trendDays.last, today);
    verify(() => getWaterInRangeUseCase(from: today.subtract(const Duration(days: 6)), to: today)).called(1);
    verifyNoMoreInteractions(getWaterInRangeUseCase);
  });

  blocTest<WaterHistoryCubit, WaterHistoryState>(
    'going to the previous month emits the new month immediately, then its logs',
    build: () => CubitsFactories.buildWaterHistoryCubit(
      getWaterInRangeUseCase: stubbedRange({
        DateTime(2026, 6, 10): DailyWater(
          entries: [WaterLog(id: 'a', loggedDate: DateTime(2026, 6, 10), amountMl: 500)],
        ),
      }),
      getWaterGoalUseCase: stubbedGoal(),
    ),
    act: (cubit) => cubit.goToPreviousMonth(),
    expect: () => [
      isA<WaterHistoryState>().having((state) => state.waterInMonth, 'waterInMonth', isEmpty),
      isA<WaterHistoryState>().having((state) => state.waterInMonth, 'waterInMonth', isNotEmpty),
    ],
  );

  blocPresentationTest<WaterHistoryCubit, WaterHistoryState, WaterHistoryPresentationEvent>(
    'emits WaterHistoryError when a range query fails',
    build: () {
      final getWaterInRangeUseCase = MockGetWaterInRangeUseCase();
      when(
        () => getWaterInRangeUseCase(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildWaterHistoryCubit(getWaterInRangeUseCase: getWaterInRangeUseCase, getWaterGoalUseCase: stubbedGoal());
    },
    act: (cubit) => cubit.changeTrendRange(TrendRange.week),
    expectPresentation: () => [
      isA<WaterHistoryShowLoading>(),
      isA<WaterHistoryError>().having((event) => event.message, 'message', 'boom'),
      isA<WaterHistoryHideLoading>(),
    ],
  );
}
