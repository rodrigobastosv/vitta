import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

Future<void> pumpChart(WidgetTester tester, VTBarChart chart) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: SizedBox(width: 300, child: chart)),
  ),
);

void main() {
  test('a bar totals its segments so stacked and plain bars share one scale', () {
    const bar = VTBarChartBar(
      segments: [
        VTBarChartSegment(value: 30, color: VTColors.macroProtein),
        VTBarChartSegment(value: 120, color: VTColors.macroCarbs),
        VTBarChartSegment(value: 50, color: VTColors.macroFat),
      ],
    );

    expect(bar.total, 200);
  });

  test('an empty bar carries no segments and totals zero', () {
    expect(const VTBarChartBar.empty().total, 0);
    expect(const VTBarChartBar.empty().segments, isEmpty);
  });

  testWidgets('paints without overflowing when bars, a reference line and gaps are mixed', (tester) async {
    await pumpChart(
      tester,
      const VTBarChart(
        bars: [
          VTBarChartBar(segments: [VTBarChartSegment(value: 1800, color: VTColors.green)]),
          VTBarChartBar.empty(),
          VTBarChartBar(segments: [VTBarChartSegment(value: 2400, color: VTColors.warning)]),
        ],
        referenceValue: 2000,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VTBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('survives a reference line taller than every bar', (tester) async {
    await pumpChart(
      tester,
      const VTBarChart(
        bars: [
          VTBarChartBar(segments: [VTBarChartSegment(value: 100, color: VTColors.green)]),
        ],
        referenceValue: 5000,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders nothing to paint when every bar is empty', (tester) async {
    await pumpChart(tester, const VTBarChart(bars: [VTBarChartBar.empty(), VTBarChartBar.empty()]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('handles an empty bar list', (tester) async {
    await pumpChart(tester, const VTBarChart(bars: []));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
