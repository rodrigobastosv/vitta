import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_stepper.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpStepper(WidgetTester tester, TextEditingController controller) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(body: VTStepper(controller: controller)),
  ),
);

void main() {
  testWidgets('increments a whole count by one', (tester) async {
    final controller = TextEditingController(text: '2');
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(controller.text, '3');
  });

  testWidgets('increasing a fractional count snaps up to the next whole number', (tester) async {
    final controller = TextEditingController(text: '0.9');
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(controller.text, '1');
  });

  testWidgets('decreasing a fractional count snaps down to the enclosing whole number', (tester) async {
    final controller = TextEditingController(text: '1.9');
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();

    expect(controller.text, '1');
  });

  testWidgets('will not step below the minimum', (tester) async {
    final controller = TextEditingController(text: '1');
    addTearDown(controller.dispose);
    await pumpStepper(tester, controller);

    expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove_rounded)).onPressed, isNull);
  });
}
