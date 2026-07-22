import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_finished_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpFinishedCard(
  WidgetTester tester, {
  int estimatedCalories = 320,
  bool isBodyWeightKnown = true,
  Locale locale = const Locale('en'),
  double width = 320,
  VoidCallback? onViewSummary,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WorkoutFinishedCard(
          estimatedCalories: estimatedCalories,
          isBodyWeightKnown: isBodyWeightKnown,
          onViewSummary: onViewSummary,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('leads with the estimated burn', (tester) async {
    await pumpFinishedCard(tester);

    expect(find.text('~320 kcal'), findsOneWidget);
    expect(find.text('Estimated burn'), findsOneWidget);
  });

  testWidgets('says the figure is rough when no weight has been logged', (tester) async {
    await pumpFinishedCard(tester, isBodyWeightKnown: false);

    expect(find.text('A rough figure — log your body weight for a closer one.'), findsOneWidget);
  });

  testWidgets('claims the weight only once one has been logged', (tester) async {
    await pumpFinishedCard(tester);

    expect(find.text('A rough figure — log your body weight for a closer one.'), findsNothing);
    expect(find.text('Worked out from your weight, what you trained and how long it takes.'), findsOneWidget);
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('fits a 320px screen in ${locale.languageCode}', (tester) async {
      await pumpFinishedCard(tester, estimatedCalories: 1234, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('offers a way back to the summary when a callback is passed', (tester) async {
    var opened = 0;
    await pumpFinishedCard(tester, onViewSummary: () => opened++);

    await tester.tap(find.text('View summary'));

    expect(opened, 1);
  });

  testWidgets('renders no CTA when there is nowhere to go', (tester) async {
    await pumpFinishedCard(tester);

    expect(find.text('View summary'), findsNothing);
  });
}
