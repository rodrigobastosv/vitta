import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';
import 'package:vitta/app/presentation/pages/paywall/widgets/paywall_plan_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required bool isLoaded,
    PremiumOffer? offer,
    VoidCallback? onRetry,
    Locale locale = const Locale('en'),
  }) => tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PaywallPlanCard(isLoaded: isLoaded, onRetry: onRetry ?? () {}, offer: offer),
      ),
    ),
  );

  // The regression this whole state exists for: a null offer used to mean both
  // "still asking the store" and "asked, nothing to sell", so every open of the
  // paywall showed "Subscriptions aren't available right now" for the length of
  // the round trip - on the most scrutinised screen in the app.
  testWidgets('shows a skeleton, not the unavailable message, before the store answers', (tester) async {
    await pumpCard(tester, isLoaded: false);

    expect(find.byType(VTSkeleton), findsWidgets);
    expect(find.textContaining("aren't available"), findsNothing);
  });

  testWidgets('offers a retry once the store has answered with nothing', (tester) async {
    var retries = 0;
    await pumpCard(tester, isLoaded: true, onRetry: () => retries++);

    expect(find.byType(VTSkeleton), findsNothing);
    expect(find.textContaining("aren't available"), findsOneWidget);

    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('names the price and the period the store reported', (tester) async {
    await pumpCard(
      tester,
      isLoaded: true,
      offer: const PremiumOffer(packageId: r'$rc_monthly', productId: 'vitta_premium_monthly', priceLabel: r'$4.99', period: .monthly),
    );

    expect(find.text(r'$4.99'), findsOneWidget);
    expect(find.text('per month'), findsOneWidget);
  });

  // The period is the store's, not ours: the label used to hardcode "/month",
  // so pointing the RevenueCat offering at an annual package would have made the
  // paywall misstate what the user is charged.
  testWidgets('follows the store to an annual period rather than assuming monthly', (tester) async {
    await pumpCard(
      tester,
      isLoaded: true,
      offer: const PremiumOffer(packageId: r'$rc_annual', productId: 'vitta_premium_annual', priceLabel: r'$39.99', period: .annual),
    );

    expect(find.text('per year'), findsOneWidget);
    expect(find.text('per month'), findsNothing);
  });

  // A package the store describes as custom carries no period we can name, and
  // naming one anyway would be a false claim about the charge.
  testWidgets('states the price alone when the store reports no period', (tester) async {
    await pumpCard(
      tester,
      isLoaded: true,
      offer: const PremiumOffer(packageId: 'custom', productId: 'vitta_premium_custom', priceLabel: r'$9.99'),
    );

    expect(find.text(r'$9.99'), findsOneWidget);
    expect(find.textContaining('per '), findsNothing);
  });

  testWidgets('is localized in Portuguese', (tester) async {
    await pumpCard(
      tester,
      isLoaded: true,
      locale: const Locale('pt'),
      offer: const PremiumOffer(packageId: r'$rc_monthly', productId: 'vitta_premium_monthly', priceLabel: r'R$ 14,90', period: .monthly),
    );

    expect(find.text('por mês'), findsOneWidget);
  });
}
