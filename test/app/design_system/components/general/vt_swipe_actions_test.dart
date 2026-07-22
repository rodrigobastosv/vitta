import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_swipe_actions.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<({int deletes, int leadingTriggers})> pumpAndSwipe(WidgetTester tester, {required bool endToStart, required bool withLeading}) async {
  var deletes = 0;
  var leadingTriggers = 0;
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VTSwipeActions(
          itemKey: const ValueKey('reminder-1'),
          onDelete: () => deletes++,
          deleteLabel: 'Delete',
          leading: withLeading
              ? VTSwipeAction(onTrigger: () => leadingTriggers++, icon: Icons.check_rounded, color: VTColors.success, semanticLabel: 'Complete')
              : null,
          child: const SizedBox(height: 64, child: Text('Pay the bill')),
        ),
      ),
    ),
  );

  await tester.fling(find.text('Pay the bill'), Offset(endToStart ? -400 : 400, 0), 1000);
  await tester.pumpAndSettle();
  return (deletes: deletes, leadingTriggers: leadingTriggers);
}

void main() {
  testWidgets('swiping from the end deletes', (tester) async {
    final result = await pumpAndSwipe(tester, endToStart: true, withLeading: true);

    expect(result.deletes, 1);
    expect(result.leadingTriggers, 0);
  });

  testWidgets('swiping start-to-end fires the leading action and snaps back without deleting', (tester) async {
    final result = await pumpAndSwipe(tester, endToStart: false, withLeading: true);

    expect(result.leadingTriggers, 1);
    expect(result.deletes, 0);
    expect(find.text('Pay the bill'), findsOneWidget);
  });

  testWidgets('without a leading action a start-to-end swipe does nothing', (tester) async {
    final result = await pumpAndSwipe(tester, endToStart: false, withLeading: false);

    expect(result.deletes, 0);
    expect(result.leadingTriggers, 0);
  });
}
