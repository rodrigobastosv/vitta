import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpInApp(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('a ring announces its readout as one item rather than three', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpInApp(
      tester,
      const VTMacroRing(
        value: 0.9,
        color: Colors.green,
        child: Column(mainAxisSize: .min, children: [Text('1850'), Text('of 2000 kcal'), Text('150 left')]),
      ),
    );

    expect(find.bySemanticsLabel('1850\nof 2000 kcal\n150 left'), findsOneWidget);
    expect(find.bySemanticsLabel('1850'), findsNothing);

    handle.dispose();
  });

  testWidgets('a painted chart is silent until it is given a summary', (tester) async {
    final handle = tester.ensureSemantics();
    const bars = [
      VTBarChartBar(segments: [VTBarChartSegment(value: 1800, color: Colors.green)]),
    ];

    await pumpInApp(tester, const VTBarChart(bars: bars));
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);

    await pumpInApp(tester, const VTBarChart(bars: bars, semanticLabel: 'Daily calories, 7 days, averaging 1,850 kcal'));
    expect(find.bySemanticsLabel('Daily calories, 7 days, averaging 1,850 kcal'), findsOneWidget);

    handle.dispose();
  });
}
