import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/reminder_day/reminder_day_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/reminder_factory.dart';

void main() {
  Future<void> pumpDay(WidgetTester tester, {required DateTime date, required List reminders}) => tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReminderDayPage(date: date, reminders: reminders.cast()),
    ),
  );

  testWidgets('lists the day reminders read-only (no delete, checkbox disabled)', (tester) async {
    await pumpDay(
      tester,
      date: DateTime(2026, 7, 18),
      reminders: [ReminderFactory.build(title: 'Pay rent')],
    );

    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
  });

  testWidgets('shows the empty state with no reminders', (tester) async {
    await pumpDay(tester, date: DateTime(2026, 7, 18), reminders: const []);

    expect(find.text('No reminders'), findsOneWidget);
  });
}
