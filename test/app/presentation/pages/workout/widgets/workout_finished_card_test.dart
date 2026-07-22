import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_finished_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpCard(WidgetTester tester, {VoidCallback? onViewSummary}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: WorkoutFinishedCard(onViewSummary: onViewSummary),
    ),
  ),
);

void main() {
  testWidgets('offers a way back to the summary when a callback is passed', (tester) async {
    var opened = 0;
    await pumpCard(tester, onViewSummary: () => opened++);

    await tester.tap(find.text('View summary'));

    expect(opened, 1);
  });

  testWidgets('renders no CTA when there is nowhere to go', (tester) async {
    await pumpCard(tester);

    expect(find.text('View summary'), findsNothing);
  });
}
