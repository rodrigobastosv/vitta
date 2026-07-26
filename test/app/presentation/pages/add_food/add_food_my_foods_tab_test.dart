import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_extra.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../fixtures/premium_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

Future<void> pumpAddFood(WidgetTester tester, {List<Food> myFoods = const [], Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final getRecentlyLoggedFoodsUseCase = MockGetRecentlyLoggedFoodsUseCase();
  when(() => getRecentlyLoggedFoodsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => const Success(<FoodLogEntry>[]));
  final getFavoriteFoodsUseCase = MockGetFavoriteFoodsUseCase();
  when(getFavoriteFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
  final getRecentSearchesUseCase = MockGetRecentSearchesUseCase();
  when(getRecentSearchesUseCase.call).thenReturn(const []);
  final getMyFoodsUseCase = MockGetMyFoodsUseCase();
  when(getMyFoodsUseCase.call).thenAnswer((_) async => Success(myFoods));

  if (G.isRegistered<AddFoodCubit>()) {
    G.unregister<AddFoodCubit>();
  }
  G.registerFactory<AddFoodCubit>(
    () => CubitsFactories.buildAddFoodCubit(
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
}

void main() {
  testWidgets('the foods this user added are one tap away, in their own tab', (tester) async {
    await pumpAddFood(tester, myFoods: [FoodFactory.build(id: 'mine-1', name: 'Granola caseira')]);

    expect(find.text('Granola caseira'), findsNothing, reason: 'the search tab is what opens');

    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();

    expect(find.text('Granola caseira'), findsOneWidget);
  });

  testWidgets('a user who has added nothing is told what the tab is for', (tester) async {
    await pumpAddFood(tester);

    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing added yet'), findsOneWidget);
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('the four tab labels fit a 320px screen in ${locale.languageCode}', (tester) async {
      await pumpAddFood(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
