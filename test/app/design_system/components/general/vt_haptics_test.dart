import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

List<String> recordHaptics(WidgetTester tester) {
  final fired = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      fired.add(call.arguments as String? ?? 'vibrate');
    }
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
  return fired;
}

Future<void> pumpInApp(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('every intent maps to a distinct platform feedback', (tester) async {
    final fired = recordHaptics(tester);

    await VTHaptics.selection();
    await VTHaptics.success();
    await VTHaptics.warning();
    await VTHaptics.error();

    expect(fired, ['HapticFeedbackType.selectionClick', 'HapticFeedbackType.lightImpact', 'HapticFeedbackType.mediumImpact', 'HapticFeedbackType.heavyImpact']);
  });

  testWidgets('a segmented tab ticks on a real change but not on re-tapping the current tab', (tester) async {
    final fired = recordHaptics(tester);
    await pumpInApp(
      tester,
      VTSegmentedTabs<int>(
        tabs: const [
          VTSegmentedTab(value: 0, label: 'One'),
          VTSegmentedTab(value: 1, label: 'Two'),
        ],
        selected: 0,
        onSelected: (_) {},
      ),
    );

    await tester.tap(find.text('One'));
    await tester.pump();
    expect(fired, isEmpty);

    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(fired, ['HapticFeedbackType.selectionClick']);
  });

  testWidgets('a slider ticks per division crossed, not per pixel dragged', (tester) async {
    final fired = recordHaptics(tester);
    var value = 0.0;
    await pumpInApp(
      tester,
      StatefulBuilder(
        builder: (context, setState) => VTLabeledSlider(
          label: 'Protein',
          valueLabel: '${value.round()}',
          value: value,
          min: 0,
          max: 1000,
          color: Colors.red,
          onChanged: (newValue) => setState(() => value = newValue),
        ),
      ),
    );

    final slider = tester.getCenter(find.byType(Slider));
    final gesture = await tester.startGesture(Offset(tester.getTopLeft(find.byType(Slider)).dx + 24, slider.dy));
    for (var step = 0; step < 20; step++) {
      await gesture.moveBy(const Offset(4, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();

    expect(fired, isNotEmpty);
    expect(fired.length, lessThan(20));
  });
}
