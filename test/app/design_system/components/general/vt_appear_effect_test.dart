import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

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

  testWidgets('stays hidden until its staggered turn comes round', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VTAppearEffect(index: 3, child: Text('hi'))));

    await tester.pump(VTMotion.staggerFor(3) - const Duration(milliseconds: 1));
    expect(opacityOf(tester), 0);

    await tester.pumpAndSettle();
    expect(opacityOf(tester), 1);
  });

  testWidgets('caps the stagger so a long list does not make the last item wait', (tester) async {
    expect(VTMotion.staggerFor(50), VTMotion.staggerFor(VTMotion.maxStaggerSteps));
    expect(VTMotion.staggerFor(50).inMilliseconds, lessThan(VTMotion.entrance.inMilliseconds));
  });
}
