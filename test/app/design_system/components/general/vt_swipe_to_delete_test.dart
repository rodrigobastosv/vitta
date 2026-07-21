import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_swipe_to_delete.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<int> swipeAway(WidgetTester tester, {required bool endToStart}) async {
  var deletes = 0;
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VTSwipeToDelete(
          itemKey: const ValueKey('log-1'),
          onDelete: () => deletes++,
          child: const SizedBox(height: 64, child: Text('Oatmeal')),
        ),
      ),
    ),
  );

  await tester.fling(find.text('Oatmeal'), Offset(endToStart ? -400 : 400, 0), 1000);
  await tester.pumpAndSettle();
  return deletes;
}

void main() {
  testWidgets('swiping from the end deletes', (tester) async {
    expect(await swipeAway(tester, endToStart: true), 1);
  });

  testWidgets('swiping the other way does nothing, so a scroll-back never deletes', (tester) async {
    expect(await swipeAway(tester, endToStart: false), 0);
  });
}
