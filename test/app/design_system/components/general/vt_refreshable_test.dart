import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pullDown(WidgetTester tester, Widget refreshable) async {
  await tester.pumpWidget(MaterialApp(theme: VTTheme.light, home: Scaffold(body: refreshable)));
  await tester.fling(find.byType(Scaffold), const Offset(0, 400), 1000);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows its children rather than the empty state once there is data', (tester) async {
    await pullDown(
      tester,
      VTRefreshable(
        onRefresh: () async {},
        emptyState: const Center(child: Text('Nothing logged yet')),
        children: const [Text('a logged day')],
      ),
    );

    expect(find.text('a logged day'), findsOneWidget);
    expect(find.text('Nothing logged yet'), findsNothing);
  });

  testWidgets('a full list refreshes on pull', (tester) async {
    var refreshes = 0;
    await pullDown(tester, VTRefreshable(onRefresh: () async => refreshes++, children: const [Text('one'), Text('two')]));

    expect(refreshes, 1);
  });

  testWidgets('a short list still refreshes rather than refusing the gesture', (tester) async {
    var refreshes = 0;
    await pullDown(tester, VTRefreshable(onRefresh: () async => refreshes++, children: const [Text('one')]));

    expect(refreshes, 1);
  });

  testWidgets('an empty state refreshes too — the screen a new user most wants to retry on', (tester) async {
    var refreshes = 0;
    await pullDown(
      tester,
      VTRefreshable(
        onRefresh: () async => refreshes++,
        hasData: false,
        emptyState: const Center(child: Text('Nothing logged yet')),
        children: const [],
      ),
    );

    expect(refreshes, 1);
  });
}
