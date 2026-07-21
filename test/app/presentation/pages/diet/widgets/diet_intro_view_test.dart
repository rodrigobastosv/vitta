import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_intro_view.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpIntro(WidgetTester tester, {required VoidCallback onSetGoals, required VoidCallback onSkip}) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DietIntroView(onSetGoals: onSetGoals, onSkip: onSkip),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('explains logging, recipes and goals', (tester) async {
    await pumpIntro(tester, onSetGoals: () {}, onSkip: () {});

    expect(find.text('Welcome to Diet'), findsOneWidget);
    expect(find.text('Build recipes'), findsOneWidget);
    expect(find.text('Set a goal that fits you'), findsOneWidget);
  });

  testWidgets('the primary action takes the user to set goals', (tester) async {
    var goals = false;
    await pumpIntro(tester, onSetGoals: () => goals = true, onSkip: () {});

    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Set my goals')).onPressed!();

    expect(goals, isTrue);
  });

  testWidgets('skipping dismisses without setting goals', (tester) async {
    var skipped = false;
    await pumpIntro(tester, onSetGoals: () {}, onSkip: () => skipped = true);

    tester.widget<TextButton>(find.widgetWithText(TextButton, 'Skip for now')).onPressed!();

    expect(skipped, isTrue);
  });
}
