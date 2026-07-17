import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_intro_view.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpIntro(
  WidgetTester tester, {
  required VoidCallback onCreateRoutine,
  required VoidCallback onSkip,
}) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WorkoutIntroView(onCreateRoutine: onCreateRoutine, onSkip: onSkip),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('explains the feature and what a routine is', (tester) async {
    await pumpIntro(tester, onCreateRoutine: () {}, onSkip: () {});

    expect(find.text('Welcome to Workout'), findsOneWidget);
    expect(find.text('What is a routine?'), findsOneWidget);
  });

  testWidgets('the primary action asks to create the first routine', (tester) async {
    var created = false;
    await pumpIntro(tester, onCreateRoutine: () => created = true, onSkip: () {});

    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Create my first routine')).onPressed!();

    expect(created, isTrue);
  });

  testWidgets('skipping dismisses without creating a routine', (tester) async {
    var skipped = false;
    await pumpIntro(tester, onCreateRoutine: () {}, onSkip: () => skipped = true);

    tester.widget<TextButton>(find.widgetWithText(TextButton, 'Skip for now')).onPressed!();

    expect(skipped, isTrue);
  });
}
