import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_swipe_actions.dart';
import 'package:vitta/app/design_system/components/inputs/vt_check_circle.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/reminder_factory.dart';

Future<void> pumpTile(WidgetTester tester, {required Reminder reminder, bool readOnly = false}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ReminderTile(
        reminder: reminder,
        onToggle: readOnly ? null : (_) {},
        onTap: readOnly ? null : () {},
        onDelete: readOnly ? null : () {},
      ),
    ),
  ),
);

void main() {
  testWidgets('flags an overdue reminder with a badge', (tester) async {
    await pumpTile(tester, reminder: ReminderFactory.build(dueDate: DateTime(2020), remindAt: DateTime(2020, 1, 1, 9)));

    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('a completed reminder is not overdue and offers no swipe-to-complete', (tester) async {
    await pumpTile(
      tester,
      reminder: ReminderFactory.build(dueDate: DateTime(2020), remindAt: DateTime(2020, 1, 1, 9), completedAt: DateTime(2020, 1, 1, 10)),
    );

    expect(find.text('Overdue'), findsNothing);
    expect(tester.widget<VTSwipeActions>(find.byType(VTSwipeActions)).leading, isNull);
  });

  testWidgets('an actionable reminder can be swiped to complete', (tester) async {
    await pumpTile(tester, reminder: ReminderFactory.build());

    expect(tester.widget<VTSwipeActions>(find.byType(VTSwipeActions)).leading, isNotNull);
    expect(find.byType(VTCheckCircle), findsOneWidget);
  });

  testWidgets('a read-only tile has no swipe actions', (tester) async {
    await pumpTile(tester, reminder: ReminderFactory.build(), readOnly: true);

    expect(find.byType(VTSwipeActions), findsNothing);
  });
}
