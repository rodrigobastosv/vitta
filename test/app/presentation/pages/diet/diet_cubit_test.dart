import 'dart:async';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/domain/sync/entities/sync_topic.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

// Loading a day now also reads the range behind the week strip and the streak,
// so every test that loads one has to answer it - the same tax stubbing the
// routine cycle puts on the workout tests.
MockGetMacrosInRangeUseCase _noRangeUseCase() {
  final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
  when(
    () => getMacrosInRangeUseCase(
      from: any(named: 'from'),
      to: any(named: 'to'),
    ),
  ).thenAnswer((_) async => const Success(<DateTime, DailyMacros>{}));
  return getMacrosInRangeUseCase;
}

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
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        getMacroGoalsUseCase: getMacroGoalsUseCase,
      );
    },
    act: (cubit) => cubit.loadToday(),
    expect: () => [isA<DietState>()],
  );

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'the first load shows no overlay - the skeleton covers it',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        getMacroGoalsUseCase: getMacroGoalsUseCase,
      );
    },
    act: (cubit) => cubit.loadToday(),
    expectPresentation: () => <DietPresentationEvent>[],
  );

  test('a day the device has seen before opens on its cached copy, before the network answers', () async {
    final cachedEntry = FoodLogEntryFactory.build();
    final getCachedDailyMacrosUseCase = MockGetCachedDailyMacrosUseCase();
    when(() => getCachedDailyMacrosUseCase(date: any(named: 'date'))).thenReturn(DailyMacros(entries: [cachedEntry]));
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final networkRead = Completer<Result<VTError, DailyMacros>>();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) => networkRead.future);
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getCachedDailyMacrosUseCase: getCachedDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );

    unawaited(cubit.loadToday());
    await pumpEventQueue();

    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.dailyMacros.entries, [cachedEntry]);

    networkRead.complete(const Success(DailyMacros(entries: [])));
    await pumpEventQueue();

    expect(cubit.state.dailyMacros.entries, isEmpty);
    await cubit.close();
  });

  test('refreshing the day on screen never rewinds it to the cached copy', () async {
    final staleEntry = FoodLogEntryFactory.build();
    final getCachedDailyMacrosUseCase = MockGetCachedDailyMacrosUseCase();
    when(() => getCachedDailyMacrosUseCase(date: any(named: 'date'))).thenReturn(DailyMacros(entries: [staleEntry]));
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getCachedDailyMacrosUseCase: getCachedDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );
    await cubit.loadToday();

    final states = <DietState>[];
    final subscription = cubit.stream.listen(states.add);
    await cubit.refresh();
    await pumpEventQueue();

    expect(states.where((state) => state.dailyMacros.entries.isNotEmpty), isEmpty);
    await subscription.cancel();
    await cubit.close();
  });

  test('loadToday keeps the previous state when it fails', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );
    final initialState = cubit.state;

    await cubit.loadToday();

    expect(cubit.state, initialState.copyWith(isLoaded: true));
  });

  test('a failed first load still marks itself loaded, so the page falls through to its empty state', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );

    expect(cubit.state.isLoaded, isFalse);

    await cubit.loadToday();

    expect(cubit.state.isLoaded, isTrue);
  });

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'emits DietError when loadToday fails',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        getMacroGoalsUseCase: getMacroGoalsUseCase,
      );
    },
    act: (cubit) => cubit.loadToday(),
    expectPresentation: () => [isA<DietError>()],
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
        getMacrosInRangeUseCase: _noRangeUseCase(),
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
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        getDailyMacrosUseCase: getDailyMacrosUseCaseSpy,
        deleteFoodLogUseCase: deleteFoodLogUseCase,
      );
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expectPresentation: () => [isA<DietError>()],
    verify: (_) => verifyNever(() => getDailyMacrosUseCaseSpy(date: any(named: 'date'))),
  );

  test('updateLog reloads the day it is showing and logs a food_log_updated action', () async {
    final loggingService = useMockLog();
    final updateFoodLogUseCase = MockUpdateFoodLogUseCase();
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(
      () => updateFoodLogUseCase(logId: 'log-1', mealType: .dinner, quantity: const LoggedQuantity.weight(250)),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      updateFoodLogUseCase: updateFoodLogUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );
    await cubit.goToDate(DateTime(2026, 7, 10));

    final updatedResult = await cubit.updateLog(logId: 'log-1', mealType: .dinner, quantity: const LoggedQuantity.weight(250));

    updatedResult.when((error) => fail('expected Success, got Failure($error)'), (_) {});
    verify(() => getDailyMacrosUseCase(date: DateTime(2026, 7, 10))).called(2);
    final captured = verify(() => loggingService.logAction(captureAny(), data: captureAny(named: 'data'))).captured;
    expect(captured, [
      'food_log_updated',
      {'meal': 'dinner'},
    ]);
  });

  final getDailyMacrosUseCaseUpdateSpy = MockGetDailyMacrosUseCase();
  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'updateLog returns the failure without reloading or emitting an error dialog',
    build: () {
      final updateFoodLogUseCase = MockUpdateFoodLogUseCase();
      when(
        () => updateFoodLogUseCase(logId: 'log-1', mealType: .dinner, quantity: const LoggedQuantity.weight(250)),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        getDailyMacrosUseCase: getDailyMacrosUseCaseUpdateSpy,
        updateFoodLogUseCase: updateFoodLogUseCase,
      );
    },
    act: (cubit) async {
      final updatedResult = await cubit.updateLog(logId: 'log-1', mealType: .dinner, quantity: const LoggedQuantity.weight(250));
      expect(updatedResult.when((error) => error.message, (_) => null), 'boom');
    },
    expectPresentation: () => <DietPresentationEvent>[],
    verify: (_) => verifyNever(() => getDailyMacrosUseCaseUpdateSpy(date: any(named: 'date'))),
  );

  test('unitSystem reads the current app settings', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings(unitSystem: .imperial));
    final cubit = CubitsFactories.buildDietCubit(getMacrosInRangeUseCase: _noRangeUseCase(), getAppSettingsUseCase: getAppSettingsUseCase);

    expect(cubit.unitSystem, UnitSystem.imperial);
  });

  test('isViewingToday is true right after construction', () {
    final cubit = CubitsFactories.buildDietCubit(getMacrosInRangeUseCase: _noRangeUseCase());
    final today = DateTime.now();

    expect(cubit.state.date, DateTime(today.year, today.month, today.day));
    expect(cubit.isViewingToday, isTrue);
  });

  blocTest<DietCubit, DietState>(
    'goToPreviousDay emits the new date immediately, then the loaded state',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => Success(DailyMacros(entries: [FoodLogEntryFactory.build()])));
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        getMacroGoalsUseCase: getMacroGoalsUseCase,
      );
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
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );
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
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );
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
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );

    await cubit.goToDate(DateTime(2026, 1, 5, 13, 30));

    expect(cubit.state.date, DateTime(2026, 1, 5));
  });

  test('refresh reloads the currently selected date', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final cubit = CubitsFactories.buildDietCubit(
      getMacrosInRangeUseCase: _noRangeUseCase(),
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
    );
    await cubit.goToDate(DateTime(2026, 1, 5));

    await cubit.refresh();

    expect(cubit.state.date, DateTime(2026, 1, 5));
    verify(() => getDailyMacrosUseCase(date: DateTime(2026, 1, 5))).called(2);
  });

  test('loadMonthMacros stores the macros-by-date returned for the month', () async {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    final macrosByDate = {
      DateTime(2026, 7, 5): DailyMacros(entries: [FoodLogEntryFactory.build()]),
      DateTime(2026, 7, 11): const DailyMacros(entries: []),
    };
    when(
      () => getMacrosInRangeUseCase(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => Success(macrosByDate));
    final cubit = CubitsFactories.buildDietCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);

    await cubit.loadMonthMacros(DateTime(2026, 7));

    expect(cubit.state.macrosByDate, macrosByDate);
    verify(() => getMacrosInRangeUseCase(from: DateTime(2026, 7), to: DateTime(2026, 7, 31))).called(1);
  });

  test('loadMonthMacros keeps the previous macros when it fails', () async {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(
      () => getMacrosInRangeUseCase(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final cubit = CubitsFactories.buildDietCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);

    await cubit.loadMonthMacros(DateTime(2026, 7));

    expect(cubit.state.macrosByDate, isEmpty);
  });

  test('loading a day counts the streak from the days that came back with it', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final loggedDays = {
      for (var offset = 0; offset < 3; offset++) DateTime(today.year, today.month, today.day - offset): DailyMacros(entries: [FoodLogEntryFactory.build()]),
    };
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(loggedDays));
    final cubit = CubitsFactories.buildDietCubit(
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
      getMacrosInRangeUseCase: getMacrosInRangeUseCase,
    );

    await cubit.loadToday();

    expect(cubit.state.streak.days, 3);
    await cubit.close();
  });

  // A day whose last entry was deleted comes back absent from the range, and
  // merging over the map would leave its dot on the strip and its link in the
  // streak forever.
  test('a day that lost its last entry is dropped from the map, not merged over', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer(
      (_) async => Success({
        today: DailyMacros(entries: [FoodLogEntryFactory.build()]),
        yesterday: DailyMacros(entries: [FoodLogEntryFactory.build()]),
      }),
    );
    final cubit = CubitsFactories.buildDietCubit(
      getDailyMacrosUseCase: getDailyMacrosUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
      getMacrosInRangeUseCase: getMacrosInRangeUseCase,
    );
    await cubit.loadToday();
    expect(cubit.state.macrosByDate.keys, contains(yesterday));

    when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer(
      (_) async => Success({
        today: DailyMacros(entries: [FoodLogEntryFactory.build()]),
      }),
    );
    await cubit.refresh();

    expect(cubit.state.macrosByDate.keys, isNot(contains(yesterday)));
    expect(cubit.state.streak.days, 1);
    await cubit.close();
  });

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'onInit asks to show the intro when it has not been seen yet',
    build: () {
      final hasSeenDietIntroUseCase = MockHasSeenDietIntroUseCase();
      when(hasSeenDietIntroUseCase.call).thenReturn(false);
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      final watchDataChangesUseCase = MockWatchDataChangesUseCase();
      when(() => watchDataChangesUseCase(topics: any(named: 'topics'))).thenAnswer((_) => const Stream<SyncTopic>.empty());
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        hasSeenDietIntroUseCase: hasSeenDietIntroUseCase,
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        getMacroGoalsUseCase: getMacroGoalsUseCase,
        watchDataChangesUseCase: watchDataChangesUseCase,
      );
    },
    act: (cubit) => cubit.onInit(),
    expectPresentation: () => [isA<DietShowIntro>()],
  );

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'onInit does not show the intro once it has been seen',
    build: () {
      final hasSeenDietIntroUseCase = MockHasSeenDietIntroUseCase();
      when(hasSeenDietIntroUseCase.call).thenReturn(true);
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      final watchDataChangesUseCase = MockWatchDataChangesUseCase();
      when(() => watchDataChangesUseCase(topics: any(named: 'topics'))).thenAnswer((_) => const Stream<SyncTopic>.empty());
      return CubitsFactories.buildDietCubit(
        getMacrosInRangeUseCase: _noRangeUseCase(),
        hasSeenDietIntroUseCase: hasSeenDietIntroUseCase,
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        getMacroGoalsUseCase: getMacroGoalsUseCase,
        watchDataChangesUseCase: watchDataChangesUseCase,
      );
    },
    act: (cubit) => cubit.onInit(),
    expectPresentation: () => <DietPresentationEvent>[],
  );

  test('markIntroSeen records that the intro was seen', () async {
    final markDietIntroSeenUseCase = MockMarkDietIntroSeenUseCase();
    when(markDietIntroSeenUseCase.call).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildDietCubit(getMacrosInRangeUseCase: _noRangeUseCase(), markDietIntroSeenUseCase: markDietIntroSeenUseCase);

    await cubit.markIntroSeen();

    verify(markDietIntroSeenUseCase.call).called(1);
  });
}
