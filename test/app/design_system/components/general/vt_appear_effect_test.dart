import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';

void main() {
  double opacityOf(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.ancestor(of: find.text('hi'), matching: find.byType(FadeTransition)).first).opacity.value;

  testWidgets('starts hidden and fades its child in', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VTAppearEffect(child: Text('hi'))));

    expect(opacityOf(tester), 0);

    await tester.pumpAndSettle();

    expect(opacityOf(tester), 1);
    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('stays hidden until its delay elapses', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VTAppearEffect(delay: Duration(milliseconds: 200), child: Text('hi')),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(opacityOf(tester), 0);

    await tester.pumpAndSettle();
    expect(opacityOf(tester), 1);
  });
}
