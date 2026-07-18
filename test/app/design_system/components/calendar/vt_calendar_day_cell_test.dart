import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_day_cell.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> _pump(WidgetTester tester, {required bool isFuture, required VoidCallback onTap, Color? valueColor}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: VTCalendarDayCell(day: DateTime(2026, 7, 20), isToday: false, isFuture: isFuture, valueColor: valueColor, onTap: onTap),
    ),
  ),
);

void main() {
  testWidgets('a future day with a value is tappable (reminders live in the future)', (tester) async {
    var tapped = false;
    await _pump(tester, isFuture: true, valueColor: Colors.green, onTap: () => tapped = true);

    await tester.tap(find.text('20'));
    expect(tapped, isTrue);
  });

  testWidgets('a day without a value is not tappable', (tester) async {
    var tapped = false;
    await _pump(tester, isFuture: false, onTap: () => tapped = true);

    await tester.tap(find.text('20'));
    expect(tapped, isFalse);
  });
}
