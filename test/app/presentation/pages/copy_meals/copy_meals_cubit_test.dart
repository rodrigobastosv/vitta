import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_presentation_event.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<FoodLogEntry>[]);
  });

  final sourceDate = DateTime(2026, 7, 10);
  final targetDate = DateTime(2026, 7, 14);

  FoodLogEntry buildEntry(MealType mealType) => FoodLogEntryFactory.build(log: FoodLogFactory.build(mealType: mealType));

  MockGetMacrosInRangeUseCase buildMacrosInRangeUseCase(Map<DateTime, DailyMacros> macrosByDate) {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(
      () => getMacrosInRangeUseCase(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => Success(macrosByDate));
    return getMacrosInRangeUseCase;
  }

  test('starts on the target date month with nothing selected', () {
    final cubit = CubitsFactories.buildCopyMealsCubit(targetDate: targetDate);

    expect(cubit.state.targetDate, targetDate);
    expect(cubit.state.month, DateTime(2026, 7));
    expect(cubit.state.sourceDate, isNull);
    expect(cubit.state.canCopy, isFalse);
  });

  test('picking a source day preselects every meal logged on it', () async {
    final cubit = CubitsFactories.buildCopyMealsCubit(
      getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
        sourceDate: DailyMacros(entries: [buildEntry(MealType.breakfast), buildEntry(MealType.lunch)]),
      }),
      getMacroGoalsUseCase: _stubbedGoals(),
      targetDate: targetDate,
    );

    await cubit.refresh();
    cubit.selectSourceDate(sourceDate);

    expect(cubit.state.selectedMealTypes, {MealType.breakfast, MealType.lunch});
    expect(cubit.state.entriesToCopy, hasLength(2));
  });

  test('unticking a meal drops its entries but keeps the rest copyable', () async {
    final cubit = CubitsFactories.buildCopyMealsCubit(
      getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
        sourceDate: DailyMacros(entries: [buildEntry(MealType.breakfast), buildEntry(MealType.lunch)]),
      }),
      getMacroGoalsUseCase: _stubbedGoals(),
      targetDate: targetDate,
    );

    await cubit.refresh();
    cubit.selectSourceDate(sourceDate);
    cubit.toggleMeal(MealType.breakfast);

    expect(cubit.state.selectedMealTypes, {MealType.lunch});
    expect(cubit.state.entriesToCopy, hasLength(1));
    expect(cubit.state.canCopy, isTrue);
  });

  test('unticking every meal makes the day uncopyable', () async {
    final cubit = CubitsFactories.buildCopyMealsCubit(
      getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
        sourceDate: DailyMacros(entries: [buildEntry(MealType.breakfast)]),
      }),
      getMacroGoalsUseCase: _stubbedGoals(),
      targetDate: targetDate,
    );

    await cubit.refresh();
    cubit.selectSourceDate(sourceDate);
    cubit.toggleMeal(MealType.breakfast);

    expect(cubit.state.canCopy, isFalse);
  });

  test('copy sends only the selected meals entries to the target date', () async {
    final copyFoodLogsUseCase = MockCopyFoodLogsUseCase();
    when(
      () => copyFoodLogsUseCase(
        entries: any(named: 'entries'),
        targetDate: any(named: 'targetDate'),
      ),
    ).thenAnswer((_) async => const Success(null));
    final lunchEntry = buildEntry(MealType.lunch);
    final cubit = CubitsFactories.buildCopyMealsCubit(
      getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
        sourceDate: DailyMacros(entries: [buildEntry(MealType.breakfast), lunchEntry]),
      }),
      getMacroGoalsUseCase: _stubbedGoals(),
      copyFoodLogsUseCase: copyFoodLogsUseCase,
      targetDate: targetDate,
    );

    await cubit.refresh();
    cubit.selectSourceDate(sourceDate);
    cubit.toggleMeal(MealType.breakfast);
    await cubit.copy();

    verify(() => copyFoodLogsUseCase(entries: [lunchEntry], targetDate: targetDate)).called(1);
  });

  test('months already loaded are kept, so a source picked on one month survives browsing away', () async {
    final cubit = CubitsFactories.buildCopyMealsCubit(
      getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
        sourceDate: DailyMacros(entries: [buildEntry(MealType.dinner)]),
      }),
      getMacroGoalsUseCase: _stubbedGoals(),
      targetDate: targetDate,
    );

    await cubit.refresh();
    cubit.selectSourceDate(sourceDate);
    await cubit.goToPreviousMonth();

    expect(cubit.state.month, DateTime(2026, 6));
    expect(cubit.state.sourceDate, sourceDate);
    expect(cubit.state.canCopy, isTrue);
  });

  blocTest<CopyMealsCubit, CopyMealsState>(
    'going to the previous month emits the new month immediately, then its macros',
    build: () => CubitsFactories.buildCopyMealsCubit(
      getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
        DateTime(2026, 6, 10): DailyMacros(entries: [buildEntry(MealType.snack)]),
      }),
      targetDate: targetDate,
    ),
    act: (cubit) => cubit.goToPreviousMonth(),
    expect: () => [
      isA<CopyMealsState>().having((state) => state.month, 'month', DateTime(2026, 6)).having((state) => state.macrosByDate, 'macrosByDate', isEmpty),
      isA<CopyMealsState>().having((state) => state.macrosByDate, 'macrosByDate', isNotEmpty),
    ],
  );

  blocPresentationTest<CopyMealsCubit, CopyMealsState, CopyMealsPresentationEvent>(
    'emits MealsCopied with the copied meal count once the copy succeeds',
    build: () {
      final copyFoodLogsUseCase = MockCopyFoodLogsUseCase();
      when(
        () => copyFoodLogsUseCase(
          entries: any(named: 'entries'),
          targetDate: any(named: 'targetDate'),
        ),
      ).thenAnswer((_) async => const Success(null));
      return CubitsFactories.buildCopyMealsCubit(
        getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
          sourceDate: DailyMacros(entries: [buildEntry(MealType.breakfast), buildEntry(MealType.lunch)]),
        }),
        getMacroGoalsUseCase: _stubbedGoals(),
        copyFoodLogsUseCase: copyFoodLogsUseCase,
        targetDate: targetDate,
      );
    },
    act: (cubit) async {
      await cubit.refresh();
      cubit.selectSourceDate(sourceDate);
      await cubit.copy();
    },
    expectPresentation: () => [
      isA<CopyMealsShowLoading>(),
      isA<CopyMealsHideLoading>(),
      isA<CopyMealsShowLoading>(),
      isA<CopyMealsHideLoading>(),
      isA<MealsCopied>().having((event) => event.mealCount, 'mealCount', 2),
    ],
  );

  blocPresentationTest<CopyMealsCubit, CopyMealsState, CopyMealsPresentationEvent>(
    'emits CopyMealsError when the copy fails',
    build: () {
      final copyFoodLogsUseCase = MockCopyFoodLogsUseCase();
      when(
        () => copyFoodLogsUseCase(
          entries: any(named: 'entries'),
          targetDate: any(named: 'targetDate'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildCopyMealsCubit(
        getMacrosInRangeUseCase: buildMacrosInRangeUseCase({
          sourceDate: DailyMacros(entries: [buildEntry(MealType.breakfast)]),
        }),
        getMacroGoalsUseCase: _stubbedGoals(),
        copyFoodLogsUseCase: copyFoodLogsUseCase,
        targetDate: targetDate,
      );
    },
    act: (cubit) async {
      await cubit.refresh();
      cubit.selectSourceDate(sourceDate);
      await cubit.copy();
    },
    expectPresentation: () => [
      isA<CopyMealsShowLoading>(),
      isA<CopyMealsHideLoading>(),
      isA<CopyMealsShowLoading>(),
      isA<CopyMealsHideLoading>(),
      isA<CopyMealsError>().having((event) => event.message, 'message', 'boom'),
    ],
  );
}

MockGetMacroGoalsUseCase _stubbedGoals() {
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
  return getMacroGoalsUseCase;
}
