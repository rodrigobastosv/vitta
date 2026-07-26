import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpTabs(WidgetTester tester, {required List<String> labels, double width = 320}) {
  tester.view.physicalSize = Size(width, 200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      home: Scaffold(
        body: VTSegmentedTabs<String>(
          tabs: [for (final label in labels) VTSegmentedTab(value: label, label: label)],
          selected: labels.first,
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a label too wide for its segment is scaled down, never truncated or overflowed', (tester) async {
    await pumpTabs(tester, labels: ['Search', 'Recent', 'Favorites', 'Mine']);

    expect(tester.takeException(), isNull);
    expect(find.text('Favorites'), findsOneWidget, reason: 'the whole word stays on screen rather than becoming an ellipsis');
    final paintedWidth = tester.getRect(find.text('Favorites')).width;
    expect(paintedWidth, lessThan(tester.getSize(find.text('Favorites')).width));
    expect(paintedWidth, lessThanOrEqualTo(320 / 4));
  });

  testWidgets('a label that already fits is left at its natural size', (tester) async {
    await pumpTabs(tester, labels: ['Search', 'Recent']);

    expect(tester.getRect(find.text('Recent')).width, tester.getSize(find.text('Recent')).width);
  });
}
