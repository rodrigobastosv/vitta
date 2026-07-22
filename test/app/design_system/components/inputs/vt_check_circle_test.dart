import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/inputs/vt_check_circle.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<bool?> pumpCircle(WidgetTester tester, {required bool value, ValueChanged<bool>? onChanged}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      home: Scaffold(body: Center(child: VTCheckCircle(value: value, onChanged: onChanged))),
    ),
  );
  return null;
}

void main() {
  testWidgets('shows the check glyph when completed', (tester) async {
    await pumpCircle(tester, value: true);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('tapping reports the toggled value', (tester) async {
    bool? reported;
    await pumpCircle(tester, value: false, onChanged: (value) => reported = value);

    await tester.tap(find.byType(VTCheckCircle));
    await tester.pump();

    expect(reported, isTrue);
  });

  testWidgets('a null onChanged is not tappable', (tester) async {
    await pumpCircle(tester, value: false);

    expect(tester.widget<InkResponse>(find.byType(InkResponse)).onTap, isNull);
  });
}
