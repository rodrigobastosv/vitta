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

Future<void> pumpSelectableChip(WidgetTester tester, ThemeData theme) =>
    tester.pumpWidget(MaterialApp(theme: theme, home: const Scaffold(body: SelectableChip())));

Color? chipFill(WidgetTester tester) => (tester.widget<Ink>(find.byType(Ink)).decoration! as ShapeDecoration).color;

Future<void> expectNoFillFlash(WidgetTester tester, ThemeData theme) async {
  await pumpSelectableChip(tester, theme);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(ChoiceChip));
  await tester.pump();

  for (var frame = 0; frame < 12; frame++) {
    expect(chipFill(tester)!.toARGB32(), theme.colorScheme.primaryContainer.toARGB32());
    await tester.pump(const Duration(milliseconds: 20));
  }

  await tester.pumpAndSettle();
  expect(chipFill(tester), theme.colorScheme.primaryContainer);
}

class SelectableChip extends StatefulWidget {
  const SelectableChip({super.key});

  @override
  State<SelectableChip> createState() => _SelectableChipState();
}

class _SelectableChipState extends State<SelectableChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    selected: _selected,
    label: const Text('chip'),
    onSelected: (selected) => setState(() => _selected = selected),
  );
}

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

  testWidgets('a chip fills primaryContainer from the first frame of selection in light', (tester) async {
    await expectNoFillFlash(tester, VTTheme.light);
  });

  testWidgets('a chip fills primaryContainer from the first frame of selection in dark', (tester) async {
    await expectNoFillFlash(tester, VTTheme.dark);
  });
}
