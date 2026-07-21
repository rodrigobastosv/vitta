import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/inputs/vt_weight_picker.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<double?> pumpPicker(WidgetTester tester, {double initialValue = 71.8}) async {
  tester.view.physicalSize = const Size(360, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  double? changed;
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      home: Scaffold(
        body: VTWeightPicker(initialValue: initialValue, onChanged: (value) => changed = value, unitLabel: 'kg', min: 30, max: 250),
      ),
    ),
  );
  return changed;
}

void main() {
  testWidgets('opens at the initial value with no overflow', (tester) async {
    await pumpPicker(tester);

    expect(find.text('71.8'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling the ruler reports a new value', (tester) async {
    await pumpPicker(tester);

    await tester.drag(find.byType(VTWeightPicker), const Offset(-60, 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The read-out is no longer the starting weight after scrolling right.
    expect(find.text('71.8'), findsNothing);
  });
}
