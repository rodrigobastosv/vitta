import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/presentation/pages/paywall/widgets/paywall_legal_footer.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

void main() {
  Future<void> pumpFooter(WidgetTester tester, {Locale locale = const Locale('en')}) => tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: PaywallLegalFooter()),
    ),
  );

  // App Review checks a subscription paywall for exactly these three things, and
  // their absence is one of the most common rejections - so they are asserted
  // rather than left to inspection.
  testWidgets('shows the terms link, the privacy link and the auto-renewal disclosure', (tester) async {
    await pumpFooter(tester);

    expect(find.widgetWithText(TextButton, 'Terms of Use'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Privacy Policy'), findsOneWidget);
    expect(find.textContaining('renews automatically'), findsOneWidget);
  });

  testWidgets('states where the subscription can be cancelled', (tester) async {
    await pumpFooter(tester);

    expect(find.textContaining('cancel'), findsWidgets);
    expect(find.textContaining('App Store account settings'), findsOneWidget);
  });

  testWidgets('is localized in Portuguese', (tester) async {
    await pumpFooter(tester, locale: const Locale('pt'));

    expect(find.widgetWithText(TextButton, 'Termos de Uso'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Política de Privacidade'), findsOneWidget);
    expect(find.textContaining('renovada automaticamente'), findsOneWidget);
  });
}
