import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/profile/widgets/profile_app_version.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpVersion(WidgetTester tester, {required String version, String buildNumber = '42', Locale locale = const Locale('en')}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ProfileAppVersion(version: version, buildNumber: buildNumber)),
      ),
    );

void main() {
  testWidgets('states the version and the build it came from', (tester) async {
    await pumpVersion(tester, version: '1.4.2', buildNumber: '87');

    expect(find.text('Version 1.4.2 (87)'), findsOneWidget);
  });

  testWidgets('says nothing at all when the platform could not answer', (tester) async {
    await pumpVersion(tester, version: '', buildNumber: '');

    expect(find.byType(Text), findsNothing);
  });

  testWidgets('is localized', (tester) async {
    await pumpVersion(tester, version: '1.4.2', buildNumber: '87', locale: const Locale('pt'));

    expect(find.text('Versão 1.4.2 (87)'), findsOneWidget);
  });
}
