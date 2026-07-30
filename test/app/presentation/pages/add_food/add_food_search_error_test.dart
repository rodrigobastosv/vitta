import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/recent_meal.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_extra.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../fixtures/premium_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

const _apiFailure = VTError(message: 'Request to https://world.openfoodfacts.org/cgi/search.pl?search_terms=banana failed with status 502');

Future<void> pumpFailingSearch(WidgetTester tester, {Locale locale = const Locale('en')}) async {
  final searchFoodsUseCase = MockSearchFoodsUseCase();
  when(() => searchFoodsUseCase(query: any(named: 'query'))).thenAnswer((_) async => const Failure(_apiFailure));
  final getRecentlyLoggedFoodsUseCase = MockGetRecentlyLoggedFoodsUseCase();
  when(() => getRecentlyLoggedFoodsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => const Success(<FoodLogEntry>[]));
  final getFavoriteFoodsUseCase = MockGetFavoriteFoodsUseCase();
  when(getFavoriteFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
  final getRecentSearchesUseCase = MockGetRecentSearchesUseCase();
  when(getRecentSearchesUseCase.call).thenReturn(const []);
  final getMyFoodsUseCase = MockGetMyFoodsUseCase();
  when(getMyFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));

  if (G.isRegistered<AddFoodCubit>()) {
    G.unregister<AddFoodCubit>();
  }
  G.registerFactory<AddFoodCubit>(
    () => CubitsFactories.buildAddFoodCubit(
      getRecentMealsUseCase: _noRecentMealsUseCase(),
      searchFoodsUseCase: searchFoodsUseCase,
      getRecentlyLoggedFoodsUseCase: getRecentlyLoggedFoodsUseCase,
      getFavoriteFoodsUseCase: getFavoriteFoodsUseCase,
      getRecentSearchesUseCase: getRecentSearchesUseCase,
      getMyFoodsUseCase: getMyFoodsUseCase,
    ),
  );
  addTearDown(() => G.unregister<AddFoodCubit>());

  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: withTestPremium(AddFoodPage(extra: AddFoodExtra(loggedDate: DateTime(2026, 7, 26)))),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), 'banana');
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

// onInit now also reads the recent meals behind the Recent tab, so any test that
// builds the cubit has to answer it - the tax the routine cycle already puts on
// the workout tests.
MockGetRecentMealsUseCase _noRecentMealsUseCase() {
  final getRecentMealsUseCase = MockGetRecentMealsUseCase();
  when(() => getRecentMealsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => const Success(<RecentMeal>[]));
  return getRecentMealsUseCase;
}

void main() {
  testWidgets('a failed food search reads as a generic message, never as the API failure', (tester) async {
    await pumpFailingSearch(tester);

    expect(find.text("We couldn't complete that. Check your connection and try again."), findsOneWidget);
    expect(find.textContaining('openfoodfacts'), findsNothing);
    expect(find.textContaining('502'), findsNothing);
    expect(find.textContaining('Request to'), findsNothing);
  });

  testWidgets('the generic message is localized', (tester) async {
    await pumpFailingSearch(tester, locale: const Locale('pt'));

    expect(find.text('Não conseguimos concluir. Verifique sua conexão e tente novamente.'), findsOneWidget);
    expect(find.textContaining('failed with status'), findsNothing);
  });
}
