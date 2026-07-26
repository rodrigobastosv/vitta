import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_page.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/macro_gap_card.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/suggested_meal_card.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/suggested_meal_item_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/meal_suggestions_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

const _goals = MacroGoals.defaultGoals;

MealSuggestionCubit buildCubit({
  Result<VTError, MealSuggestions>? suggestionsResult,
  Result<VTError, DailyMacros> dayResult = const Success(DailyMacros(entries: [])),
  Duration? dayDelay,
}) {
  final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
  when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async {
    if (dayDelay != null) {
      await Future<void>.delayed(dayDelay);
    }
    return dayResult;
  });
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(getMacroGoalsUseCase.call).thenReturn(_goals);
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
  final suggestMealsUseCase = MockSuggestMealsUseCase();
  when(
    () => suggestMealsUseCase(
      mealType: any(named: 'mealType'),
      loggedToday: any(named: 'loggedToday'),
      goals: any(named: 'goals'),
      languageCode: any(named: 'languageCode'),
    ),
  ).thenAnswer((_) async => suggestionsResult ?? Success(MealSuggestionsFactory.build()));
  return CubitsFactories.buildMealSuggestionCubit(
    suggestMealsUseCase: suggestMealsUseCase,
    getDailyMacrosUseCase: getDailyMacrosUseCase,
    getMacroGoalsUseCase: getMacroGoalsUseCase,
    getAppSettingsUseCase: getAppSettingsUseCase,
  );
}

Widget buildTestApp({required MealSuggestionCubit cubit}) {
  if (G.isRegistered<MealSuggestionCubit>()) {
    G.unregister<MealSuggestionCubit>();
  }
  G.registerFactoryParam<MealSuggestionCubit, DateTime, void>((_, _) => cubit);
  return MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MealSuggestionPage(loggedDate: DateTime(2026, 7, 19)),
    builder: (context, child) => LoaderOverlay(child: child!),
  );
}

Future<void> pumpPage(WidgetTester tester, Widget app, {Size size = const Size(1200, 3600)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(MealType.lunch);
    registerFallbackValue(const DailyMacros(entries: []));
    registerFallbackValue(_goals);
  });

  testWidgets('the page opens on the day gap and offers to ask, not on a list of meals', (tester) async {
    await pumpPage(tester, buildTestApp(cubit: buildCubit()));

    expect(find.byType(MacroGapCard), findsOneWidget);
    expect(find.text('Suggest meals'), findsOneWidget);
    expect(find.byType(SuggestedMealCard), findsNothing);
  });

  // The first read shows a skeleton, never the empty-looking page it would
  // otherwise render before the day is known.
  testWidgets('the first read shows a skeleton rather than an empty gap', (tester) async {
    // A deliberately slow read, because the point is the frame before the day is
    // known: an empty MacroGapCard there would read as "nothing left to eat".
    await tester.pumpWidget(buildTestApp(cubit: buildCubit(dayDelay: const Duration(seconds: 1))));
    await tester.pump();

    expect(find.byType(VTSkeleton), findsWidgets);
    expect(find.byType(MacroGapCard), findsNothing);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(MacroGapCard), findsOneWidget);
  });

  testWidgets('asking lists the options and the items of the one picked', (tester) async {
    final cubit = buildCubit(
      suggestionsResult: Success(
        MealSuggestions(
          meals: [
            MealSuggestionsFactory.buildMeal(
              items: [MealSuggestionsFactory.buildItem(name: 'Chicken'), MealSuggestionsFactory.buildItem(name: 'Rice')],
            ),
            MealSuggestionsFactory.buildMeal(name: 'Omelette', items: [MealSuggestionsFactory.buildItem(name: 'Egg', quantityGrams: 90)]),
          ],
        ),
      ),
    );
    await pumpPage(tester, buildTestApp(cubit: cubit));

    await tester.tap(find.text('Suggest meals'));
    await tester.pumpAndSettle();

    expect(find.byType(SuggestedMealCard), findsNWidgets(2));
    expect(find.byType(SuggestedMealItemCard), findsNWidgets(2));
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('Egg'), findsNothing);
  });

  testWidgets('picking another option swaps the items under it', (tester) async {
    final cubit = buildCubit(
      suggestionsResult: Success(
        MealSuggestions(
          meals: [
            MealSuggestionsFactory.buildMeal(items: [MealSuggestionsFactory.buildItem(name: 'Chicken')]),
            MealSuggestionsFactory.buildMeal(name: 'Omelette', items: [MealSuggestionsFactory.buildItem(name: 'Egg', quantityGrams: 120)]),
          ],
        ),
      ),
    );
    await pumpPage(tester, buildTestApp(cubit: cubit));

    await tester.tap(find.text('Suggest meals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Omelette'));
    await tester.pumpAndSettle();

    expect(find.text('Egg'), findsOneWidget);
    expect(find.byType(SuggestedMealItemCard), findsOneWidget);
    // Keyed by the option as well as the position, so the amount field is not
    // left holding the previous option's text.
    expect(find.widgetWithText(SuggestedMealItemCard, '120'), findsOneWidget);
  });

  // The one primary action lives in the bottom bar in every state, so the
  // found-nothing state must not add a second button asking for the same retry.
  testWidgets('finding nothing explains itself without a second retry button', (tester) async {
    final cubit = buildCubit(suggestionsResult: const Success(MealSuggestions(meals: [])));
    await pumpPage(tester, buildTestApp(cubit: cubit));

    await tester.tap(find.text('Suggest meals'));
    await tester.pumpAndSettle();

    expect(find.byType(VTEmptyState), findsOneWidget);
    expect(find.byType(VTPrimaryButton), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

}
