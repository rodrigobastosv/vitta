import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpCelebration(WidgetTester tester, {required bool trigger, bool disableAnimations = false}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Center(
          child: VTCelebration(trigger: trigger, child: const Text('done')),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('paints nothing until the milestone is reached', (tester) async {
    await pumpCelebration(tester, trigger: false);
    await tester.pumpAndSettle();

    expect(find.byKey(VTCelebration.burstKey), findsNothing);
    expect(find.text('done'), findsOneWidget);
  });

  testWidgets('bursts when the trigger flips, then clears itself away', (tester) async {
    await pumpCelebration(tester, trigger: false);
    await tester.pumpAndSettle();

    await pumpCelebration(tester, trigger: true);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(VTCelebration.burstKey), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.byKey(VTCelebration.burstKey), findsNothing);
  });

  testWidgets('a rebuild with the trigger already set does not re-fire', (tester) async {
    await pumpCelebration(tester, trigger: true);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(VTCelebration.burstKey), findsWidgets);

    await tester.pumpAndSettle();

    await pumpCelebration(tester, trigger: true);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(VTCelebration.burstKey), findsNothing);
  });

  testWidgets('respects the reduce-motion accessibility setting', (tester) async {
    await pumpCelebration(tester, trigger: true, disableAnimations: true);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(VTCelebration.burstKey), findsNothing);
    expect(find.text('done'), findsOneWidget);
  });
}
