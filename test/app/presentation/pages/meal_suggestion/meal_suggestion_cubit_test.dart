import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/premium_required_error.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_presentation_event.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/meal_suggestions_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

const _goals = MacroGoals.defaultGoals;

MockGetDailyMacrosUseCase _dayReturning(DailyMacros dailyMacros) {
  final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
  when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => Success(dailyMacros));
  return getDailyMacrosUseCase;
}

MockGetMacroGoalsUseCase _goalsReturning(MacroGoals goals) {
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(getMacroGoalsUseCase.call).thenReturn(goals);
  return getMacroGoalsUseCase;
}

MockGetAppSettingsUseCase _settingsUseCase() {
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
  return getAppSettingsUseCase;
}

MockSuggestMealsUseCase _suggesterReturning(Result<VTError, MealSuggestions> suggestionsResult) {
  final suggestMealsUseCase = MockSuggestMealsUseCase();
  when(
    () => suggestMealsUseCase(
      mealType: any(named: 'mealType'),
      loggedToday: any(named: 'loggedToday'),
      goals: any(named: 'goals'),
      languageCode: any(named: 'languageCode'),
    ),
  ).thenAnswer((_) async => suggestionsResult);
  return suggestMealsUseCase;
}

MealSuggestionCubit _loadedCubit({
  MockSuggestMealsUseCase? suggestMealsUseCase,
  MockLogSuggestedMealUseCase? logSuggestedMealUseCase,
  DailyMacros dailyMacros = const DailyMacros(entries: []),
}) => CubitsFactories.buildMealSuggestionCubit(
  suggestMealsUseCase: suggestMealsUseCase,
  logSuggestedMealUseCase: logSuggestedMealUseCase,
  getDailyMacrosUseCase: _dayReturning(dailyMacros),
  getMacroGoalsUseCase: _goalsReturning(_goals),
  getAppSettingsUseCase: _settingsUseCase(),
);

void main() {
  setUpAll(() {
    registerFallbackValue(<SuggestedMealLogItem>[]);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(MealType.lunch);
    registerFallbackValue(const DailyMacros(entries: []));
    registerFallbackValue(_goals);
  });

  blocTest<MealSuggestionCubit, MealSuggestionState>(
    'loadDay reads the day behind the gap and marks it known',
    build: () => _loadedCubit(
      dailyMacros: DailyMacros(
        entries: [FoodLogEntryFactory.build(log: FoodLogFactory.build(quantityGrams: 200), food: FoodFactory.build(caloriesPer100g: 100))],
      ),
    ),
    act: (cubit) => cubit.loadDay(),
    expect: () => [
      isA<MealSuggestionState>()
          .having((state) => state.isLoaded, 'isLoaded', isTrue)
          .having((state) => state.goals, 'goals', _goals)
          .having((state) => state.gap.calories, 'gap calories', _goals.calorieGoal - 200),
    ],
  );

  // The skeleton is the first-load indicator; the overlay is only for a reload
  // over data the page already has.
  blocPresentationTest<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
    'the first load raises no overlay',
    build: _loadedCubit,
    act: (cubit) => cubit.loadDay(),
    expectPresentation: () => <MealSuggestionPresentationEvent>[],
  );

  blocPresentationTest<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
    'a reload over a known day does raise the overlay',
    build: _loadedCubit,
    act: (cubit) async {
      await cubit.loadDay();
      await cubit.loadDay();
    },
    expectPresentation: () => [isA<MealSuggestionShowLoading>(), isA<MealSuggestionHideLoading>()],
  );

  blocTest<MealSuggestionCubit, MealSuggestionState>(
    'a failed first read still leaves the day known, so the page stops showing a skeleton',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildMealSuggestionCubit(
        getDailyMacrosUseCase: getDailyMacrosUseCase,
        getMacroGoalsUseCase: _goalsReturning(_goals),
        getAppSettingsUseCase: _settingsUseCase(),
      );
    },
    act: (cubit) => cubit.loadDay(),
    expect: () => [isA<MealSuggestionState>().having((state) => state.isLoaded, 'isLoaded', isTrue)],
  );

  blocTest<MealSuggestionCubit, MealSuggestionState>(
    'suggestMeals fills one editable row list per option, seeded with the suggested amounts',
    build: () => _loadedCubit(
      suggestMealsUseCase: _suggesterReturning(
        Success(
          MealSuggestionsFactory.build(
            meals: [
              MealSuggestionsFactory.buildMeal(items: [MealSuggestionsFactory.buildItem()]),
              MealSuggestionsFactory.buildMeal(name: 'Omelette', items: [MealSuggestionsFactory.buildItem(name: 'Egg', quantityGrams: 120.5)]),
            ],
          ),
        ),
      ),
    ),
    act: (cubit) => cubit.suggestMeals(),
    expect: () => [
      isA<MealSuggestionState>()
          .having((state) => state.hasRequested, 'hasRequested', isTrue)
          .having((state) => state.meals.map((meal) => meal.items.single.food.name).toList(), 'item names', ['Grilled chicken', 'Egg'])
          .having((state) => state.entriesByMeal.length, 'row lists', 2)
          .having((state) => state.selectedEntries.single.gramsText, 'first amount', '150')
          .having((state) => state.entriesByMeal.last.single.gramsText, 'second amount', '120.5'),
    ],
  );

  blocPresentationTest<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
    'suggestMeals shows the thinking overlay and reports an empty answer as found-nothing',
    build: () => _loadedCubit(suggestMealsUseCase: _suggesterReturning(const Success(MealSuggestions(meals: [])))),
    act: (cubit) => cubit.suggestMeals(),
    expectPresentation: () => [isA<MealSuggestionThinking>(), isA<MealSuggestionHideLoading>(), isA<MealSuggestionFoundNothing>()],
  );

  blocPresentationTest<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
    'suggestMeals surfaces a failure as an error, not as a crash',
    build: () => _loadedCubit(suggestMealsUseCase: _suggesterReturning(const Failure(VTError(message: 'boom')))),
    act: (cubit) => cubit.suggestMeals(),
    expectPresentation: () => [
      isA<MealSuggestionThinking>(),
      isA<MealSuggestionHideLoading>(),
      isA<MealSuggestionError>().having((event) => event.message, 'message', 'boom'),
    ],
  );

  // The client lock can be stale, so the function's 402 is what the page really
  // trusts - and it opens the paywall rather than reporting a failure.
  blocPresentationTest<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
    'a 402 from the function asks for premium instead of erroring',
    build: () => _loadedCubit(suggestMealsUseCase: _suggesterReturning(const Failure(PremiumRequiredError()))),
    act: (cubit) => cubit.suggestMeals(),
    expectPresentation: () => [isA<MealSuggestionThinking>(), isA<MealSuggestionHideLoading>(), isA<MealSuggestionPremiumRequired>()],
  );

  test('editing an amount on one option leaves the other option alone', () async {
    final cubit = _loadedCubit(
      suggestMealsUseCase: _suggesterReturning(
        Success(
          MealSuggestions(
            meals: [
              MealSuggestionsFactory.buildMeal(items: [MealSuggestionsFactory.buildItem()]),
              MealSuggestionsFactory.buildMeal(items: [MealSuggestionsFactory.buildItem()]),
            ],
          ),
        ),
      ),
    );

    await cubit.suggestMeals();
    cubit.gramsChanged(index: 0, text: '250');
    cubit.selectMeal(1);

    expect(cubit.state.selectedEntries.single.gramsText, '150');

    cubit.selectMeal(0);

    expect(cubit.state.selectedEntries.single.gramsText, '250');
  });

  test('canLog follows the selected option only', () async {
    final cubit = _loadedCubit(
      suggestMealsUseCase: _suggesterReturning(
        Success(
          MealSuggestions(
            meals: [
              MealSuggestionsFactory.buildMeal(items: [MealSuggestionsFactory.buildItem(), MealSuggestionsFactory.buildItem(name: 'Rice')]),
            ],
          ),
        ),
      ),
    );

    await cubit.suggestMeals();
    expect(cubit.state.canLog, isTrue);

    cubit.gramsChanged(index: 0, text: '');
    expect(cubit.state.canLog, isFalse);

    cubit.toggleIncluded(index: 0);
    expect(cubit.state.canLog, isTrue);
    expect(cubit.state.includedEntries, hasLength(1));
  });

  // A suggestion is made for one meal, so keeping lunch's options after the user
  // switches to dinner would offer to log a meal nobody asked for.
  test('changing the meal drops the options it was asked for', () async {
    final cubit = _loadedCubit(suggestMealsUseCase: _suggesterReturning(Success(MealSuggestionsFactory.build())));

    await cubit.suggestMeals();
    expect(cubit.state.meals, isNotEmpty);

    cubit.mealTypeChanged(.dinner);

    expect(cubit.state.meals, isEmpty);
    expect(cubit.state.entriesByMeal, isEmpty);
    expect(cubit.state.hasRequested, isFalse);
    expect(cubit.state.mealType, MealType.dinner);
  });

  blocPresentationTest<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
    'logMeal refuses when there is nothing valid to log',
    build: _loadedCubit,
    act: (cubit) => cubit.logMeal(),
    expectPresentation: () => [isA<MealSuggestionIncomplete>()],
  );

  final logSuggestedMealUseCase = MockLogSuggestedMealUseCase();
  blocPresentationTest<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
    'logMeal logs only the kept items of the picked option',
    build: () {
      when(
        () => logSuggestedMealUseCase(items: any(named: 'items'), loggedDate: any(named: 'loggedDate'), mealType: any(named: 'mealType')),
      ).thenAnswer((_) async => const Success(null));
      return _loadedCubit(
        logSuggestedMealUseCase: logSuggestedMealUseCase,
        suggestMealsUseCase: _suggesterReturning(
          Success(
            MealSuggestions(
              meals: [
                MealSuggestionsFactory.buildMeal(items: [MealSuggestionsFactory.buildItem(name: 'Chicken'), MealSuggestionsFactory.buildItem(name: 'Rice')]),
              ],
            ),
          ),
        ),
      );
    },
    act: (cubit) async {
      await cubit.suggestMeals();
      cubit.mealTypeChanged(.dinner);
      await cubit.suggestMeals();
      cubit.toggleIncluded(index: 1);
      cubit.gramsChanged(index: 0, text: '200');
      await cubit.logMeal();
    },
    expectPresentation: () => [
      isA<MealSuggestionThinking>(),
      isA<MealSuggestionHideLoading>(),
      isA<MealSuggestionThinking>(),
      isA<MealSuggestionHideLoading>(),
      isA<MealSuggestionShowLoading>(),
      isA<MealSuggestionHideLoading>(),
      isA<MealSuggestionLogged>().having((event) => event.mealType, 'mealType', MealType.dinner).having((event) => event.itemCount, 'itemCount', 1),
    ],
    verify: (_) {
      final captured =
          verify(
                () => logSuggestedMealUseCase(items: captureAny(named: 'items'), loggedDate: any(named: 'loggedDate'), mealType: .dinner),
              ).captured.single
              as List<SuggestedMealLogItem>;
      expect(captured.map((logItem) => logItem.food.name), ['Chicken']);
      expect(captured.single.quantityGrams, 200);
    },
  );

  test('the request carries the meal being asked about and the day behind the gap', () async {
    final suggestMealsUseCase = _suggesterReturning(Success(MealSuggestionsFactory.build()));
    final dailyMacros = DailyMacros(entries: [FoodLogEntryFactory.build(log: FoodLogFactory.build(quantityGrams: 200))]);
    final cubit = _loadedCubit(suggestMealsUseCase: suggestMealsUseCase, dailyMacros: dailyMacros);

    await cubit.loadDay();
    cubit.mealTypeChanged(.breakfast);
    await cubit.suggestMeals();

    verify(() => suggestMealsUseCase(mealType: .breakfast, loggedToday: dailyMacros, goals: _goals, languageCode: any(named: 'languageCode'))).called(1);
  });
}
