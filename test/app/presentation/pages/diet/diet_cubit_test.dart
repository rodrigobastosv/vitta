import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  blocTest<DietCubit, DietState>(
    'emits a loaded state when loadToday succeeds',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    },
    act: (cubit) => cubit.loadToday(),
    expect: () => [isA<DietState>()],
  );

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'shows then hides loading while loadToday runs',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    },
    act: (cubit) => cubit.loadToday(),
    expectPresentation: () => [isA<DietShowLoading>(), isA<DietHideLoading>()],
  );

  test('loadToday keeps the previous state when it fails', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    final initialState = cubit.state;

    await cubit.loadToday();

    expect(cubit.state, initialState);
  });

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'emits DietError when loadToday fails',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    },
    act: (cubit) => cubit.loadToday(),
    expectPresentation: () => [isA<DietShowLoading>(), isA<DietHideLoading>(), isA<DietError>()],
  );

  blocTest<DietCubit, DietState>(
    'reloads today after successfully deleting a log',
    build: () {
      final deleteFoodLogUseCase = MockDeleteFoodLogUseCase();
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(() => deleteFoodLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Success(null));
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        deleteFoodLogUseCase: deleteFoodLogUseCase,
        getMacroGoalsUseCase: getMacroGoalsUseCase,
      );
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [isA<DietState>()],
  );

  final getDailyMacrosUseCaseSpy = MockGetDailyMacrosUseCase();
  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'emits DietError without reloading when deletion fails',
    build: () {
      final deleteFoodLogUseCase = MockDeleteFoodLogUseCase();
      when(() => deleteFoodLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCaseSpy, deleteFoodLogUseCase: deleteFoodLogUseCase);
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expectPresentation: () => [isA<DietError>()],
    verify: (_) => verifyNever(() => getDailyMacrosUseCaseSpy(date: any(named: 'date'))),
  );

  test('isViewingToday is true right after construction', () {
    final cubit = CubitsFactories.buildDietCubit();
    final today = DateTime.now();

    expect(cubit.state.date, DateTime(today.year, today.month, today.day));
    expect(cubit.isViewingToday, isTrue);
  });

  blocTest<DietCubit, DietState>(
    'goToPreviousDay emits the new date immediately, then the loaded state',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(
        () => getDailyMacrosUseCase(date: any(named: 'date')),
      ).thenAnswer((_) async => Success(DailyMacros(entries: [FoodLogEntryFactory.build()])));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    },
    act: (cubit) => cubit.goToPreviousDay(),
    expect: () {
      final yesterday = DateTime.now();
      final expectedDate = DateTime(yesterday.year, yesterday.month, yesterday.day).subtract(const Duration(days: 1));
      return [
        isA<DietState>().having((state) => state.date, 'date', expectedDate).having((state) => state.dailyMacros.entries, 'entries', isEmpty),
        isA<DietState>().having((state) => state.date, 'date', expectedDate).having((state) => state.dailyMacros.entries, 'entries', isNotEmpty),
      ];
    },
  );

  test('goToPreviousDay loads the day before the currently selected date', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    final today = cubit.state.date;

    await cubit.goToPreviousDay();

    expect(cubit.state.date, today.subtract(const Duration(days: 1)));
    expect(cubit.isViewingToday, isFalse);
  });

  test('goToNextDay loads the day after the currently selected date', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    final today = cubit.state.date;
    await cubit.goToPreviousDay();

    await cubit.goToNextDay();

    expect(cubit.state.date, today);
    expect(cubit.isViewingToday, isTrue);
  });

  test('goToDate jumps directly to an arbitrary date', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);

    await cubit.goToDate(DateTime(2026, 1, 5, 13, 30));

    expect(cubit.state.date, DateTime(2026, 1, 5));
  });

  test('refresh reloads the currently selected date', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, getMacroGoalsUseCase: getMacroGoalsUseCase);
    await cubit.goToDate(DateTime(2026, 1, 5));

    await cubit.refresh();

    expect(cubit.state.date, DateTime(2026, 1, 5));
    verify(() => getDailyMacrosUseCase(date: DateTime(2026, 1, 5))).called(2);
  });

  test('loadMonthMacros stores the macros-by-date returned for the month', () async {
    final getMonthlyMacrosUseCase = MockGetMonthlyMacrosUseCase();
    final macrosByDate = {
      DateTime(2026, 7, 5): DailyMacros(entries: [FoodLogEntryFactory.build()]),
      DateTime(2026, 7, 11): const DailyMacros(entries: []),
    };
    when(
      () => getMonthlyMacrosUseCase(from: any(named: 'from'), to: any(named: 'to')),
    ).thenAnswer((_) async => Success(macrosByDate));
    final cubit = CubitsFactories.buildDietCubit(getMonthlyMacrosUseCase: getMonthlyMacrosUseCase);

    await cubit.loadMonthMacros(DateTime(2026, 7));

    expect(cubit.state.loggedMacrosInMonth, macrosByDate);
    verify(() => getMonthlyMacrosUseCase(from: DateTime(2026, 7), to: DateTime(2026, 7, 31))).called(1);
  });

  test('loadMonthMacros keeps the previous macros when it fails', () async {
    final getMonthlyMacrosUseCase = MockGetMonthlyMacrosUseCase();
    when(
      () => getMonthlyMacrosUseCase(from: any(named: 'from'), to: any(named: 'to')),
    ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final cubit = CubitsFactories.buildDietCubit(getMonthlyMacrosUseCase: getMonthlyMacrosUseCase);

    await cubit.loadMonthMacros(DateTime(2026, 7));

    expect(cubit.state.loggedMacrosInMonth, isEmpty);
  });
}
