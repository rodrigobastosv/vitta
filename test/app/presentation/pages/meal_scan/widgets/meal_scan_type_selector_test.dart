import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/meal_scan/widgets/meal_scan_type_selector.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpSelector(WidgetTester tester, {required ThemeData theme, MealType selected = .dinner}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: MealScanTypeSelector(selected: selected, onSelected: (_) {}),
    ),
  ),
);

double contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance ? foregroundLuminance : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance ? backgroundLuminance : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

// The colour actually painted, not the one handed to the widget: a chip's ink can
// come from the theme, and asserting the argument would miss what the user sees.
Color paintedColor(WidgetTester tester, Finder of) =>
    tester.widget<RichText>(find.descendant(of: of, matching: find.byType(RichText))).text.style!.color!;

void main() {
  testWidgets('the selected chip does not stack a checkmark on its own glyph', (tester) async {
    await pumpSelector(tester, theme: VTTheme.light);

    // Material draws the checkmark in the avatar slot, so the selected chip would
    // otherwise render the check over the meal icon (issue #235).
    expect(find.byIcon(MealType.dinner.icon), findsOneWidget);
    for (final chip in tester.widgetList<ChoiceChip>(find.byType(ChoiceChip))) {
      expect(chip.showCheckmark, isFalse);
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets('every chip glyph is legible on the fill it sits on (${brightness.name})', (tester) async {
      final theme = brightness == .light ? VTTheme.light : VTTheme.dark;
      final colorScheme = theme.colorScheme;

      await pumpSelector(tester, theme: theme);

      final selectedIcon = paintedColor(tester, find.byIcon(MealType.dinner.icon));
      final unselectedIcon = paintedColor(tester, find.byIcon(MealType.breakfast.icon));

      expect(
        contrastRatio(selectedIcon, colorScheme.primaryContainer),
        greaterThanOrEqualTo(4.5),
        reason: 'a selected chip fills with primaryContainer, and RawChip will not resolve a state colour for the avatar',
      );
      expect(contrastRatio(unselectedIcon, colorScheme.surface), greaterThanOrEqualTo(4.5));
    });

    testWidgets('a selected chip inks its label and its glyph the same (${brightness.name})', (tester) async {
      await pumpSelector(tester, theme: brightness == .light ? VTTheme.light : VTTheme.dark);

      expect(paintedColor(tester, find.text('Dinner')), paintedColor(tester, find.byIcon(MealType.dinner.icon)));
    });
  }
}
