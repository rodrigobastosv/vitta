import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_summary_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/body_weight_log_factory.dart';

// Cubit holds logs most-recent-first, which the card relies on.
Future<void> pumpCard(WidgetTester tester, {required List<BodyWeightLog> logs}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: BodyWeightSummaryCard(logs: logs, unitSystem: UnitSystem.metric)),
  ),
);

void main() {
  testWidgets('a loss reads with a downward arrow and a minus sign', (tester) async {
    await pumpCard(tester, logs: [BodyWeightLogFactory.build(id: 'new', weightKg: 72), BodyWeightLogFactory.build(id: 'old')]);

    expect(find.text('−2 kg'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
  });

  testWidgets('a gain reads with an upward arrow and a plus sign', (tester) async {
    await pumpCard(tester, logs: [BodyWeightLogFactory.build(id: 'new', weightKg: 75.5), BodyWeightLogFactory.build(id: 'old')]);

    expect(find.text('+1.5 kg'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
  });

  testWidgets('no change reads flat with no sign', (tester) async {
    await pumpCard(tester, logs: [BodyWeightLogFactory.build(id: 'new'), BodyWeightLogFactory.build(id: 'old')]);

    expect(find.byIcon(Icons.trending_flat_rounded), findsOneWidget);
    expect(find.text('0 kg'), findsOneWidget);
  });

  testWidgets('a single entry shows no delta pill', (tester) async {
    await pumpCard(tester, logs: [BodyWeightLogFactory.build()]);

    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
    expect(find.byIcon(Icons.trending_flat_rounded), findsNothing);
  });
}
