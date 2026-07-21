import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_water_fill.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

Future<void> pumpFill(WidgetTester tester, {required double value, String? semanticLabel, bool disableAnimations = false}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Center(child: VTWaterFill(value: value, color: VTColors.water, semanticLabel: semanticLabel)),
      ),
    ),
  ),
);

CustomPaint _fillPaint(WidgetTester tester) =>
    tester.widget<CustomPaint>(find.descendant(of: find.byType(VTWaterFill), matching: find.byType(CustomPaint)).first);

void main() {
  testWidgets('paints the fill', (tester) async {
    await pumpFill(tester, value: 0.5);
    await tester.pump();

    expect(find.byType(VTWaterFill), findsOneWidget);
    expect(_fillPaint(tester).painter, isNotNull);
  });

  testWidgets('an out-of-range value does not throw', (tester) async {
    await pumpFill(tester, value: 1.8);
    await tester.pump(const Duration(milliseconds: 800));

    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes an accessibility label when given one', (tester) async {
    await pumpFill(tester, value: 0.3, semanticLabel: '30% of your water goal');
    await tester.pump();

    expect(find.bySemanticsLabel('30% of your water goal'), findsOneWidget);
  });

  testWidgets('stays silent when no label is given', (tester) async {
    await pumpFill(tester, value: 0.3);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(_fillPaint(tester).painter, isNotNull);
  });

  testWidgets('still renders with reduce-motion enabled', (tester) async {
    await pumpFill(tester, value: 0.6, disableAnimations: true);
    await tester.pump();

    expect(_fillPaint(tester).painter, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
