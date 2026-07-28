import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_loading_overlay_indicator.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpRefreshable(WidgetTester tester, {required Future<void> Function() onRefresh}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(
      body: VTRefreshable(onRefresh: onRefresh, children: const [Text('a logged day')]),
    ),
  ),
);

Future<TestGesture> pullBy(WidgetTester tester, double distance) async {
  final gesture = await tester.startGesture(tester.getCenter(find.byType(Scaffold)));
  await gesture.moveBy(const Offset(0, 30));
  await gesture.moveBy(Offset(0, distance));
  await tester.pump();
  return gesture;
}

void main() {
  testWidgets("a pull reveals the app's activity ring, never Material's spinner", (tester) async {
    await pumpRefreshable(tester, onRefresh: () async {});
    final gesture = await pullBy(tester, 120);

    expect(find.byType(VTLoadingOverlayIndicator), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the ring is gone once nothing is being pulled or loaded', (tester) async {
    await pumpRefreshable(tester, onRefresh: () async {});

    expect(find.byType(VTLoadingOverlayIndicator), findsNothing);
  });

  testWidgets('a pull short of the trigger snaps back without refreshing', (tester) async {
    var refreshes = 0;
    await pumpRefreshable(tester, onRefresh: () async => refreshes++);
    final gesture = await pullBy(tester, 20);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(refreshes, 0);
    expect(find.byType(VTLoadingOverlayIndicator), findsNothing);
  });

  testWidgets('the ring holds while the refresh is in flight, then leaves', (tester) async {
    final refresh = Completer<void>();
    await pumpRefreshable(tester, onRefresh: () => refresh.future);
    final gesture = await pullBy(tester, 120);
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(VTLoadingOverlayIndicator), findsOneWidget);

    refresh.complete();
    await tester.pumpAndSettle();

    expect(find.byType(VTLoadingOverlayIndicator), findsNothing);
  });
}
