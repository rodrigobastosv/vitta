import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_quality_selector.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpSelector(WidgetTester tester, {required int? rating, required ValueChanged<int?> onChanged}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SleepQualitySelector(rating: rating, onChanged: onChanged)),
  ),
);

void main() {
  testWidgets('renders the optional-quality hint when nothing is rated', (tester) async {
    await pumpSelector(tester, rating: null, onChanged: (_) {});

    expect(find.text('Quality (optional)'), findsOneWidget);
  });

  testWidgets('describes the chosen rating in words', (tester) async {
    await pumpSelector(tester, rating: 4, onChanged: (_) {});

    expect(find.text('Great'), findsOneWidget);
  });

  testWidgets('tapping a star reports that rating', (tester) async {
    int? picked;
    await pumpSelector(tester, rating: null, onChanged: (value) => picked = value);

    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(2));

    expect(picked, 3);
  });

  testWidgets('tapping the current rating clears it', (tester) async {
    int? picked = 3;
    await pumpSelector(tester, rating: 3, onChanged: (value) => picked = value);

    await tester.tap(find.byIcon(Icons.star_rounded).at(2));

    expect(picked, isNull);
  });
}
