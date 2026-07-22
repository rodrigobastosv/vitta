import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpThemed(WidgetTester tester, ThemeData theme) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Wrap(
        children: [
          ChoiceChip(selected: true, label: const Text('selected'), onSelected: (_) {}),
          ChoiceChip(selected: false, label: const Text('unselected'), onSelected: (_) {}),
        ],
      ),
    ),
  ),
);

Color labelColor(WidgetTester tester, String label) => tester.widget<RichText>(find.byType(RichText).at(label == 'selected' ? 0 : 1)).text.style!.color!;

void main() {
  testWidgets('switching the theme survives the ThemeData lerp', (tester) async {
    await pumpThemed(tester, VTTheme.light);
    await tester.pumpAndSettle();

    await pumpThemed(tester, VTTheme.dark);
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a selected chip still inks its label onPrimaryContainer', (tester) async {
    await pumpThemed(tester, VTTheme.light);
    await tester.pumpAndSettle();

    expect(labelColor(tester, 'selected'), VTTheme.light.colorScheme.onPrimaryContainer);
    expect(labelColor(tester, 'unselected'), VTTheme.light.colorScheme.onSurfaceVariant);
  });
}
