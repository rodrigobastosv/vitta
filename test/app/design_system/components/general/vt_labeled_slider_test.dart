import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/components/inputs/vt_text_field.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpLabeledSlider(
  WidgetTester tester, {
  required List<double> emitted,
  double value = 180,
  String? valueUnit = 'g',
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: VTLabeledSlider(
        label: 'Protein',
        valueLabel: '${value.round()} g',
        value: value,
        min: 0,
        max: 300,
        step: 5,
        valueUnit: valueUnit,
        color: Colors.green,
        onChanged: emitted.add,
        decreaseTooltip: 'Decrease protein',
        increaseTooltip: 'Increase protein',
      ),
    ),
  ),
);

Future<void> typeIntoDialog(WidgetTester tester, String text) async {
  await tester.tap(find.text('180 g'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(VTTextField), text);
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('typing reaches a figure the step cannot land on', (tester) async {
    final emitted = <double>[];
    await pumpLabeledSlider(tester, emitted: emitted);

    await typeIntoDialog(tester, '181');

    expect(emitted, [181]);
  });

  testWidgets('a figure outside the bounds is rejected rather than clamped', (tester) async {
    final emitted = <double>[];
    await pumpLabeledSlider(tester, emitted: emitted);

    await typeIntoDialog(tester, '400');

    expect(emitted, isEmpty);
    expect(find.text('Between 0 and 300'), findsOneWidget);
  });

  testWidgets('dismissing the dialog leaves the value alone', (tester) async {
    final emitted = <double>[];
    await pumpLabeledSlider(tester, emitted: emitted);

    await tester.tap(find.text('180 g'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(VTTextField), '181');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(emitted, isEmpty);
  });

  testWidgets('a slider with no unit keeps an inert badge', (tester) async {
    final emitted = <double>[];
    await pumpLabeledSlider(tester, emitted: emitted, valueUnit: null);

    await tester.tap(find.text('180 g'));
    await tester.pumpAndSettle();

    expect(find.byType(VTTextField), findsNothing);
  });

  testWidgets('the tappable badge clears the tap target floor', (tester) async {
    await pumpLabeledSlider(tester, emitted: []);

    final size = tester.getSize(find.ancestor(of: find.text('180 g'), matching: find.byType(InkWell)).first);
    expect(size.height, greaterThanOrEqualTo(VTSpacing.minTapTarget));
  });
}
