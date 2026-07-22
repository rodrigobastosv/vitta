import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_chart_tooltip.dart';
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

  testWidgets('tapping a bar reveals its value tooltip and tapping again dismisses it', (tester) async {
    await pumpChart(
      tester,
      const VTBarChart(
        bars: [
          VTBarChartBar(segments: [VTBarChartSegment(value: 1800, color: VTColors.green)], tooltip: 'Jul 1 - 1800 kcal'),
          VTBarChartBar(segments: [VTBarChartSegment(value: 2400, color: VTColors.warning)], tooltip: 'Jul 2 - 2400 kcal'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(VTChartTooltip), findsNothing);

    final origin = tester.getTopLeft(find.byType(VTBarChart));
    await tester.tapAt(origin + const Offset(75, 100));
    await tester.pumpAndSettle();
    expect(find.text('Jul 1 - 1800 kcal'), findsOneWidget);

    await tester.tapAt(origin + const Offset(75, 100));
    await tester.pumpAndSettle();
    expect(find.byType(VTChartTooltip), findsNothing);
  });

  testWidgets('tapping a different bar moves the tooltip to it', (tester) async {
    await pumpChart(
      tester,
      const VTBarChart(
        bars: [
          VTBarChartBar(segments: [VTBarChartSegment(value: 1800, color: VTColors.green)], tooltip: 'Jul 1 - 1800 kcal'),
          VTBarChartBar(segments: [VTBarChartSegment(value: 2400, color: VTColors.warning)], tooltip: 'Jul 2 - 2400 kcal'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final origin = tester.getTopLeft(find.byType(VTBarChart));
    await tester.tapAt(origin + const Offset(75, 100));
    await tester.pumpAndSettle();
    expect(find.text('Jul 1 - 1800 kcal'), findsOneWidget);

    await tester.tapAt(origin + const Offset(225, 100));
    await tester.pumpAndSettle();
    expect(find.text('Jul 1 - 1800 kcal'), findsNothing);
    expect(find.text('Jul 2 - 2400 kcal'), findsOneWidget);
  });

  testWidgets('a bar with no tooltip is not tappable', (tester) async {
    await pumpChart(
      tester,
      const VTBarChart(
        bars: [
          VTBarChartBar(segments: [VTBarChartSegment(value: 1800, color: VTColors.green)]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(tester.getCenter(find.byType(VTBarChart)));
    await tester.pumpAndSettle();
    expect(find.byType(VTChartTooltip), findsNothing);
  });
}
