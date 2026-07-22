import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/presentation/pages/exercise_search/widgets/exercise_filter_chips.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpFilters(WidgetTester tester, {required ThemeData theme, ExerciseCategory? category}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ExerciseFilterChips(
        muscleGroup: null,
        category: category,
        onMuscleGroupChanged: (_) {},
        onCategoryChanged: (_) {},
        onClear: () {},
      ),
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

Color cardioIconColor(WidgetTester tester) => paintedColor(tester, find.byIcon(Icons.directions_run));

Color cardioLabelColor(WidgetTester tester) => paintedColor(tester, find.text('Cardio'));

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('the cardio chip is legible on the fill it sits on, selected or not (${brightness.name})', (tester) async {
      final theme = brightness == .light ? VTTheme.light : VTTheme.dark;
      final colorScheme = theme.colorScheme;

      await pumpFilters(tester, theme: theme);

      expect(contrastRatio(cardioIconColor(tester), colorScheme.surface), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(cardioLabelColor(tester), colorScheme.surface), greaterThanOrEqualTo(4.5));

      await pumpFilters(tester, theme: theme, category: .cardio);

      expect(
        contrastRatio(cardioIconColor(tester), colorScheme.primaryContainer),
        greaterThanOrEqualTo(4.5),
        reason: 'a selected chip fills with primaryContainer, and the glyph has to be inked for it',
      );
      expect(
        contrastRatio(cardioLabelColor(tester), colorScheme.primaryContainer),
        greaterThanOrEqualTo(4.5),
        reason: "Material inks a selected ChoiceChip's label with onSecondaryContainer - coral, on this app's green fill",
      );
    });

    testWidgets('a selected chip inks its label and its glyph the same (${brightness.name})', (tester) async {
      await pumpFilters(tester, theme: brightness == .light ? VTTheme.light : VTTheme.dark, category: .cardio);

      expect(cardioLabelColor(tester), cardioIconColor(tester));
    });
  }
}
