import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/inputs/vt_text_field.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpField(WidgetTester tester, {required bool obscurable}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: VTTextField(controller: TextEditingController(), label: 'Password', obscurable: obscurable),
    ),
  ),
);

EditableText editableText(WidgetTester tester) => tester.widget<EditableText>(find.byType(EditableText));

void main() {
  testWidgets('an obscurable field starts hidden and reveals on toggle', (tester) async {
    await pumpField(tester, obscurable: true);

    expect(editableText(tester).obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(editableText(tester).obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('a plain field carries no reveal toggle', (tester) async {
    await pumpField(tester, obscurable: false);

    expect(editableText(tester).obscureText, isFalse);
    expect(find.byTooltip('Show password'), findsNothing);
  });
}
