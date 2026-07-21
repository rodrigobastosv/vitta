import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart_point.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpChart(WidgetTester tester, List<VTLineChartPoint> points) {
  tester.view.physicalSize = const Size(320, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      home: Scaffold(body: VTLineChart(points: points)),
    ),
  );
}

void main() {
  testWidgets('renders a multi-point series without overflow', (tester) async {
    await pumpChart(tester, const [VTLineChartPoint(value: 75, label: 'Jul 1'), VTLineChartPoint(value: 74.2), VTLineChartPoint(value: 73.5, label: 'Jul 30')]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('handles a single point', (tester) async {
    await pumpChart(tester, const [VTLineChartPoint(value: 80)]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('handles an empty series', (tester) async {
    await pumpChart(tester, const []);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
