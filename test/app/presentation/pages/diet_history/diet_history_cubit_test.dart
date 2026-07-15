import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  test('starts on the current month with the default 30 day trend range', () {
    final cubit = CubitsFactories.buildDietHistoryCubit();
    final now = DateTime.now();

    expect(cubit.state.month, DateTime(now.year, now.month));
    expect(cubit.state.trendRange, TrendRange.month);
    expect(cubit.isViewingCurrentMonth, isTrue);
  });

  test('refresh queries the displayed month and the trend range separately', () async {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(
      () => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
    ).thenAnswer((_) async => const Success({}));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietHistoryCubit(
      getMacrosInRangeUseCase: getMacrosInRangeUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );

    await cubit.refresh();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    verify(
      () => getMacrosInRangeUseCase(from: DateTime(now.year, now.month), to: DateTime(now.year, now.month + 1, 0)),
    ).called(1);
    verify(() => getMacrosInRangeUseCase(from: today.subtract(const Duration(days: 29)), to: today)).called(1);
  });

  test('changing the trend range re-queries only the trend, using the new window', () async {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(
      () => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
    ).thenAnswer((_) async => const Success({}));
    final cubit = CubitsFactories.buildDietHistoryCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);

    await cubit.changeTrendRange(TrendRange.quarter);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(cubit.state.trendRange, TrendRange.quarter);
    verify(() => getMacrosInRangeUseCase(from: today.subtract(const Duration(days: 89)), to: today)).called(1);
    verifyNoMoreInteractions(getMacrosInRangeUseCase);
  });

  blocTest<DietHistoryCubit, DietHistoryState>(
    'going to the previous month emits the new month immediately, then its macros',
    build: () {
      final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
      when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer(
        (_) async => Success({DateTime(2026, 6, 10): DailyMacros(entries: [FoodLogEntryFactory.build()])}),
      );
      return CubitsFactories.buildDietHistoryCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);
    },
    act: (cubit) => cubit.goToPreviousMonth(),
    expect: () => [
      isA<DietHistoryState>().having((state) => state.macrosInMonth, 'macrosInMonth', isEmpty),
      isA<DietHistoryState>().having((state) => state.macrosInMonth, 'macrosInMonth', isNotEmpty),
    ],
  );

  test('the next month is only reachable after going back', () async {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(
      () => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
    ).thenAnswer((_) async => const Success({}));
    final cubit = CubitsFactories.buildDietHistoryCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);

    await cubit.goToPreviousMonth();
    expect(cubit.isViewingCurrentMonth, isFalse);

    await cubit.goToNextMonth();
    expect(cubit.isViewingCurrentMonth, isTrue);
  });

  blocPresentationTest<DietHistoryCubit, DietHistoryState, DietHistoryPresentationEvent>(
    'shows then hides one loading pair while a month loads',
    build: () {
      final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
      when(
        () => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
      ).thenAnswer((_) async => const Success({}));
      return CubitsFactories.buildDietHistoryCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);
    },
    act: (cubit) => cubit.goToPreviousMonth(),
    expectPresentation: () => [isA<DietHistoryShowLoading>(), isA<DietHistoryHideLoading>()],
  );

  blocPresentationTest<DietHistoryCubit, DietHistoryState, DietHistoryPresentationEvent>(
    'emits DietHistoryError when a range query fails',
    build: () {
      final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
      when(
        () => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildDietHistoryCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);
    },
    act: (cubit) => cubit.changeTrendRange(TrendRange.week),
    expectPresentation: () => [
      isA<DietHistoryShowLoading>(),
      isA<DietHistoryError>().having((event) => event.message, 'message', 'boom'),
      isA<DietHistoryHideLoading>(),
    ],
  );
}
