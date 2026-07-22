import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';
import 'package:vitta/app/domain/trends/entities/trend_direction.dart';
import 'package:vitta/app/domain/trends/entities/trends_verdict.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/trends/trends_cubit.dart';
import 'package:vitta/app/presentation/pages/trends/trends_presentation_event.dart';
import 'package:vitta/app/presentation/pages/trends/trends_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../factories/entities/sleep_log_factory.dart';
import '../../../../factories/entities/water_log_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime daysAgo(int days) => today().subtract(Duration(days: days));

DailyMacros macrosOf(double calories) => DailyMacros(
  entries: [
    FoodLogEntryFactory.build(food: FoodFactory.build(caloriesPer100g: calories), log: FoodLogFactory.build()),
  ],
);

DailyWater waterOf(double milliliters) => DailyWater(entries: [WaterLogFactory.build(amountMl: milliliters)]);

DailySleep sleepOf(int hours) => DailySleep(
  entries: [SleepLogFactory.build(bedTime: DateTime(2026, 7, 10, 22), wakeTime: DateTime(2026, 7, 10, 22).add(Duration(hours: hours)))],
);

DailyWorkout workoutOf(DateTime date) => DailyWorkout(
  date: date,
  workouts: [
    WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
      ],
    ),
  ],
);

MockGetMacrosInRangeUseCase stubbedMacros(Map<DateTime, DailyMacros> macrosByDate) {
  final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
  when(() => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(macrosByDate));
  return getMacrosInRangeUseCase;
}

MockGetMacroGoalsUseCase stubbedMacroGoals() {
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
  return getMacroGoalsUseCase;
}

MockGetWaterInRangeUseCase stubbedWater(Map<DateTime, DailyWater> waterByDate) {
  final getWaterInRangeUseCase = MockGetWaterInRangeUseCase();
  when(() => getWaterInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(waterByDate));
  return getWaterInRangeUseCase;
}

MockGetWaterGoalUseCase stubbedWaterGoal([double goalMl = 2000]) {
  final getWaterGoalUseCase = MockGetWaterGoalUseCase();
  when(getWaterGoalUseCase.call).thenReturn(goalMl);
  return getWaterGoalUseCase;
}

MockGetSleepInRangeUseCase stubbedSleep(Map<DateTime, DailySleep> sleepByDate) {
  final getSleepInRangeUseCase = MockGetSleepInRangeUseCase();
  when(() => getSleepInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(sleepByDate));
  return getSleepInRangeUseCase;
}

MockGetSleepGoalUseCase stubbedSleepGoal([double goalHours = 8]) {
  final getSleepGoalUseCase = MockGetSleepGoalUseCase();
  when(getSleepGoalUseCase.call).thenReturn(goalHours);
  return getSleepGoalUseCase;
}

MockGetDailyWorkoutsInRangeUseCase stubbedWorkouts(Map<DateTime, DailyWorkout> workoutsByDate) {
  final getDailyWorkoutsInRangeUseCase = MockGetDailyWorkoutsInRangeUseCase();
  when(
    () => getDailyWorkoutsInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
  ).thenAnswer((_) async => Success(workoutsByDate));
  return getDailyWorkoutsInRangeUseCase;
}

MockGetBodyWeightInRangeUseCase stubbedBodyWeight(List<BodyWeightLog> logs) {
  final getBodyWeightInRangeUseCase = MockGetBodyWeightInRangeUseCase();
  when(() => getBodyWeightInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(logs));
  return getBodyWeightInRangeUseCase;
}

TrendsCubit buildCubit({
  MockGetMacrosInRangeUseCase? getMacrosInRangeUseCase,
  MockGetWaterInRangeUseCase? getWaterInRangeUseCase,
  MockGetWaterGoalUseCase? getWaterGoalUseCase,
  MockGetSleepInRangeUseCase? getSleepInRangeUseCase,
  MockGetDailyWorkoutsInRangeUseCase? getDailyWorkoutsInRangeUseCase,
  MockGetBodyWeightInRangeUseCase? getBodyWeightInRangeUseCase,
}) => CubitsFactories.buildTrendsCubit(
  getMacrosInRangeUseCase: getMacrosInRangeUseCase ?? stubbedMacros(const {}),
  getMacroGoalsUseCase: stubbedMacroGoals(),
  getWaterInRangeUseCase: getWaterInRangeUseCase ?? stubbedWater(const {}),
  getWaterGoalUseCase: getWaterGoalUseCase ?? stubbedWaterGoal(),
  getSleepInRangeUseCase: getSleepInRangeUseCase ?? stubbedSleep(const {}),
  getSleepGoalUseCase: stubbedSleepGoal(),
  getDailyWorkoutsInRangeUseCase: getDailyWorkoutsInRangeUseCase ?? stubbedWorkouts(const {}),
  getBodyWeightInRangeUseCase: getBodyWeightInRangeUseCase ?? stubbedBodyWeight(const []),
);

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  test('starts on the 30 day range with nothing known yet', () {
    final cubit = buildCubit();

    expect(cubit.state.trendRange, TrendRange.month);
    expect(cubit.state.isLoaded, isFalse);
    expect(cubit.state.hasData, isFalse);
  });

  test('asks every area for twice the range so the period has one to compare against', () async {
    final getMacrosInRangeUseCase = stubbedMacros(const {});
    final getWaterInRangeUseCase = stubbedWater(const {});
    final cubit = buildCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase, getWaterInRangeUseCase: getWaterInRangeUseCase);

    await cubit.refresh();

    verify(() => getMacrosInRangeUseCase(from: daysAgo(59), to: today())).called(1);
    verify(() => getWaterInRangeUseCase(from: daysAgo(59), to: today())).called(1);
  });

  test('splits the window into the current period and the one before it', () async {
    final cubit = buildCubit(
      getMacrosInRangeUseCase: stubbedMacros({daysAgo(1): macrosOf(2200), daysAgo(40): macrosOf(2000)}),
    );

    await cubit.refresh();

    final nutrition = cubit.state.trendOf(.nutrition);
    expect(nutrition.current.average, 2200);
    expect(nutrition.previous.average, 2000);
    expect(nutrition.direction, TrendDirection.up);
  });

  test('judges only the areas that have a goal', () async {
    final cubit = buildCubit(
      getMacrosInRangeUseCase: stubbedMacros({daysAgo(1): macrosOf(2185)}),
      getWaterInRangeUseCase: stubbedWater({daysAgo(1): waterOf(2000)}),
      getSleepInRangeUseCase: stubbedSleep({daysAgo(1): sleepOf(8)}),
      getDailyWorkoutsInRangeUseCase: stubbedWorkouts({daysAgo(1): workoutOf(daysAgo(1))}),
      getBodyWeightInRangeUseCase: stubbedBodyWeight([BodyWeightLogFactory.build(loggedDate: daysAgo(1))]),
    );

    await cubit.refresh();

    expect(cubit.state.judgedAreaCount, 3);
    expect(cubit.state.onTrackAreaCount, 3);
    expect(cubit.state.verdict, TrendsVerdict.onTrack);
    expect(cubit.state.trendOf(.bodyWeight).isJudged, isFalse);
    expect(cubit.state.trendOf(.workout).isJudged, isFalse);
    expect(cubit.state.trendOf(.workout).hasData, isTrue);
  });

  test('an area that misses its goal drags the verdict down', () async {
    final cubit = buildCubit(
      getMacrosInRangeUseCase: stubbedMacros({daysAgo(1): macrosOf(2185)}),
      getWaterInRangeUseCase: stubbedWater({daysAgo(1): waterOf(500)}),
      getSleepInRangeUseCase: stubbedSleep({daysAgo(1): sleepOf(8)}),
    );

    await cubit.refresh();

    expect(cubit.state.onTrackAreaCount, 2);
    expect(cubit.state.verdict, TrendsVerdict.mixed);
  });

  test('there is no verdict at all when no goal area has data', () async {
    final cubit = buildCubit(getBodyWeightInRangeUseCase: stubbedBodyWeight([BodyWeightLogFactory.build(loggedDate: daysAgo(1))]));

    await cubit.refresh();

    expect(cubit.state.verdict, isNull);
    expect(cubit.state.hasData, isTrue);
  });

  test('changing the range re-queries the shorter window', () async {
    final getMacrosInRangeUseCase = stubbedMacros(const {});
    final cubit = buildCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase);

    await cubit.changeTrendRange(.week);

    expect(cubit.state.trendRange, TrendRange.week);
    expect(cubit.days, hasLength(7));
    verify(() => getMacrosInRangeUseCase(from: daysAgo(13), to: today())).called(1);
  });

  blocTest<TrendsCubit, TrendsState>(
    'a load marks the data known even when every area is empty',
    build: buildCubit,
    act: (cubit) => cubit.refresh(),
    verify: (cubit) {
      expect(cubit.state.isLoaded, isTrue);
      expect(cubit.state.hasData, isFalse);
    },
  );

  blocPresentationTest<TrendsCubit, TrendsState, TrendsPresentationEvent>(
    'the first load shows the skeleton, never the overlay',
    build: buildCubit,
    act: (cubit) => cubit.refresh(),
    expectPresentation: () => <TrendsPresentationEvent>[],
  );

  blocPresentationTest<TrendsCubit, TrendsState, TrendsPresentationEvent>(
    'a reload over known data shows the overlay',
    build: buildCubit,
    seed: () => const TrendsState(),
    act: (cubit) => cubit.refresh(),
    expectPresentation: () => [isA<TrendsShowLoading>(), isA<TrendsHideLoading>()],
  );

  blocPresentationTest<TrendsCubit, TrendsState, TrendsPresentationEvent>(
    'several failing areas report one error, not one each',
    build: () {
      final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
      when(
        () => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
      ).thenAnswer((_) async => const Failure(VTError(message: 'no network')));
      final getWaterInRangeUseCase = MockGetWaterInRangeUseCase();
      when(
        () => getWaterInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
      ).thenAnswer((_) async => const Failure(VTError(message: 'no network either')));
      return buildCubit(getMacrosInRangeUseCase: getMacrosInRangeUseCase, getWaterInRangeUseCase: getWaterInRangeUseCase);
    },
    act: (cubit) => cubit.refresh(),
    expectPresentation: () => [isA<TrendsError>()],
  );
}
