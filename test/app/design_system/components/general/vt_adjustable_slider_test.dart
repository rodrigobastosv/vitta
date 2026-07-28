import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_adjustable_slider.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

Future<void> pumpSlider(
  WidgetTester tester, {
  required double value,
  required List<double> emitted,
  double min = 0,
  double max = 600,
  double step = 5,
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(
      body: VTAdjustableSlider(
        value: value,
        min: min,
        max: max,
        step: step,
        color: Colors.green,
        onChanged: emitted.add,
        decreaseTooltip: 'Decrease carbs',
        increaseTooltip: 'Increase carbs',
      ),
    ),
  ),
);

void main() {
  testWidgets('the nudge buttons move the value exactly one step, in each direction', (tester) async {
    final emitted = <double>[];
    await pumpSlider(tester, value: 180, emitted: emitted);

    await tester.tap(find.byTooltip('Increase carbs'));
    await tester.pump();
    await tester.tap(find.byTooltip('Decrease carbs'));
    await tester.pump();

    expect(emitted, [185, 175]);
  });

  testWidgets('a value off the step lands on the step, not one step away from where it was', (tester) async {
    final emitted = <double>[];
    await pumpSlider(tester, value: 182, emitted: emitted);

    await tester.tap(find.byTooltip('Increase carbs'));
    await tester.pump();

    expect(emitted, [185]);
  });

  testWidgets('a drag can only ever produce a multiple of the step', (tester) async {
    final emitted = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        home: Scaffold(
          body: VTAdjustableSlider(
            value: 0,
            min: 0,
            max: 600,
            step: 5,
            color: Colors.green,
            onChanged: emitted.add,
            decreaseTooltip: 'Decrease carbs',
            increaseTooltip: 'Increase carbs',
          ),
        ),
      ),
    );

    final slider = find.byType(Slider);
    final gesture = await tester.startGesture(tester.getCenter(slider));
    for (var move = 0; move < 8; move++) {
      await gesture.moveBy(const Offset(7, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();

    expect(emitted, isNotEmpty);
    expect(emitted.where((value) => value % 5 != 0), isEmpty);
  });

  testWidgets('the buttons disable at the bounds rather than doing nothing', (tester) async {
    await pumpSlider(tester, value: 0, emitted: []);

    expect(tester.widget<IconButton>(find.ancestor(of: find.byIcon(Icons.remove), matching: find.byType(IconButton))).onPressed, isNull);
    expect(tester.widget<IconButton>(find.ancestor(of: find.byIcon(Icons.add), matching: find.byType(IconButton))).onPressed, isNotNull);
  });

  testWidgets('both nudge buttons clear the tap target floor', (tester) async {
    await pumpSlider(tester, value: 100, emitted: []);

    for (final icon in [Icons.remove, Icons.add]) {
      final size = tester.getSize(find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)));
      expect(size.width, greaterThanOrEqualTo(VTSpacing.minTapTarget));
      expect(size.height, greaterThanOrEqualTo(VTSpacing.minTapTarget));
    }
  });
}
