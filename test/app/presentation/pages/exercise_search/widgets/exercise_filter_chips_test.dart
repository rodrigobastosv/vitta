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

Color cardioIconColor(WidgetTester tester) => tester.widget<Icon>(find.byIcon(Icons.directions_run)).color!;

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('the cardio glyph is legible on the chip it sits on, selected or not (${brightness.name})', (tester) async {
      final theme = brightness == Brightness.light ? VTTheme.light : VTTheme.dark;
      final colorScheme = theme.colorScheme;

      await pumpFilters(tester, theme: theme);

      expect(contrastRatio(cardioIconColor(tester), colorScheme.surface), greaterThanOrEqualTo(4.5));

      await pumpFilters(tester, theme: theme, category: ExerciseCategory.cardio);

      expect(
        contrastRatio(cardioIconColor(tester), colorScheme.primaryContainer),
        greaterThanOrEqualTo(4.5),
        reason: 'a selected chip fills with primaryContainer, and the glyph has to be inked for it',
      );
    });
  }
}
