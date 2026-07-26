import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/meal_suggestion_action.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../fixtures/premium_fixture.dart';

void main() {
  final pushedRoutes = <String>[];

  Future<void> pumpAction(WidgetTester tester, {required bool isPremium}) async {
    final router = GoRouter(
      initialLocation: AppRoute.addFood.path,
      routes: [
        GoRoute(
          path: AppRoute.addFood.path,
          name: AppRoute.addFood.name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              actions: [MealSuggestionAction(date: DateTime(2026, 7, 19), onLogged: () {})],
            ),
          ),
        ),
        for (final route in [AppRoute.mealSuggestion, AppRoute.paywall])
          GoRoute(
            path: route.path,
            name: route.name,
            builder: (context, state) {
              pushedRoutes.add(route.name);
              return const Scaffold();
            },
          ),
      ],
    );
    await tester.pumpWidget(
      withTestPremium(
        isPremium: isPremium,
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<String?> tapAction(WidgetTester tester) async {
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    return pushedRoutes.isEmpty ? null : pushedRoutes.last;
  }

  // The lock is UX, not enforcement - the Edge Function returns 402 either way.
  // What it buys is that a free tap explains itself instead of failing.
  testWidgets('a free user is sent to the paywall instead of the suggester', (tester) async {
    await pumpAction(tester, isPremium: false);

    expect(await tapAction(tester), AppRoute.paywall.name);
  });

  testWidgets('a subscriber reaches the suggester', (tester) async {
    await pumpAction(tester, isPremium: true);

    expect(await tapAction(tester), AppRoute.mealSuggestion.name);
  });

  testWidgets('the action is badged while locked', (tester) async {
    await pumpAction(tester, isPremium: false);

    expect(find.byType(Badge), findsOneWidget);
  });

  testWidgets('the action is plain once subscribed', (tester) async {
    await pumpAction(tester, isPremium: true);

    expect(find.byType(Badge), findsNothing);
  });
}
