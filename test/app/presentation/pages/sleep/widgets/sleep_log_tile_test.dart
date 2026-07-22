import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log_source.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_log_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/sleep_log_factory.dart';

Future<void> pumpTile(WidgetTester tester, {required SleepLogSource source}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SleepLogTile(log: SleepLogFactory.build(source: source), onDelete: () {})),
  ),
);

void main() {
  testWidgets('marks a night imported from health with a Health badge', (tester) async {
    await pumpTile(tester, source: .health);

    expect(find.text('Health'), findsOneWidget);
  });

  testWidgets('a manually logged night carries no source badge', (tester) async {
    await pumpTile(tester, source: .manual);

    expect(find.text('Health'), findsNothing);
  });
}
