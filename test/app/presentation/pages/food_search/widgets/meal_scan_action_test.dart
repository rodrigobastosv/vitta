import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/meal_scan_action.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../fixtures/premium_fixture.dart';

void main() {
  final pushedRoutes = <String>[];

  Future<void> pumpAction(WidgetTester tester, {required bool isPremium}) async {
    final router = GoRouter(
      initialLocation: AppRoute.diet.path,
      routes: [
        GoRoute(
          path: AppRoute.diet.path,
          name: AppRoute.diet.name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(actions: [MealScanAction(date: DateTime(2026, 7, 19), onLogged: () {})]),
          ),
        ),
        for (final route in [AppRoute.mealScan, AppRoute.premium])
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

  // The lock is UX, not enforcement - but it is what keeps a free user from
  // reaching a scanner the Edge Function is only going to refuse.
  testWidgets('a free user is sent to the paywall instead of the scanner', (tester) async {
    await pumpAction(tester, isPremium: false);

    expect(await tapAction(tester), AppRoute.premium.name);
  });

  testWidgets('a subscriber reaches the scanner', (tester) async {
    await pumpAction(tester, isPremium: true);

    expect(await tapAction(tester), AppRoute.mealScan.name);
  });

  testWidgets('the camera icon is badged while locked', (tester) async {
    await pumpAction(tester, isPremium: false);

    expect(find.byType(Badge), findsOneWidget);
  });

  testWidgets('the camera icon is plain once subscribed', (tester) async {
    await pumpAction(tester, isPremium: true);

    expect(find.byType(Badge), findsNothing);
  });
}
