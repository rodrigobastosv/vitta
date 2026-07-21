import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/log_set_sheet.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/workout_set_factory.dart';

Future<void> pumpLogSetSheet(
  WidgetTester tester, {
  UnitSystem unitSystem = UnitSystem.metric,
  Future<Result<VTError, void>> Function({required int reps, required double weightKg})? onSubmit,
  bool editing = false,
  int? defaultReps,
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: LogSetSheet(
        unitSystem: unitSystem,
        set: editing ? WorkoutSetFactory.build(reps: 8, weightKg: 60) : null,
        defaultReps: defaultReps,
        onSubmit: onSubmit ?? ({required reps, required weightKg}) async => const Success(null),
      ),
    ),
  ),
);

void main() {
  testWidgets('names the load unit in the label, so it is readable before typing', (tester) async {
    await pumpLogSetSheet(tester);

    expect(find.text('Load (kg)'), findsOneWidget);
  });

  testWidgets('follows the imperial unit', (tester) async {
    await pumpLogSetSheet(tester, unitSystem: UnitSystem.imperial);

    expect(find.text('Load (lb)'), findsOneWidget);
  });

  testWidgets('shows the bodyweight hint in full rather than truncated inside a half-width field', (tester) async {
    await pumpLogSetSheet(tester);

    final hint = tester.widget<Text>(find.text('Leave the load empty for a bodyweight set.'));
    expect(hint.maxLines, isNull);
    expect(hint.overflow, isNull);
  });

  testWidgets('an empty load is a bodyweight set, not a validation error', (tester) async {
    double? submittedWeight;
    await pumpLogSetSheet(
      tester,
      onSubmit: ({required reps, required weightKg}) async {
        submittedWeight = weightKg;
        return const Success(null);
      },
    );

    await tester.enterText(find.byType(TextField).first, '12');
    await tester.tap(find.text('Save set'));
    await tester.pump();

    expect(submittedWeight, 0);
  });

  testWidgets('converts the typed load out of the display unit before it reaches the domain', (tester) async {
    double? submittedWeight;
    await pumpLogSetSheet(
      tester,
      unitSystem: UnitSystem.imperial,
      onSubmit: ({required reps, required weightKg}) async {
        submittedWeight = weightKg;
        return const Success(null);
      },
    );

    await tester.enterText(find.byType(TextField).first, '10');
    await tester.enterText(find.byType(TextField).last, '100');
    await tester.tap(find.text('Save set'));
    await tester.pump();

    expect(submittedWeight, closeTo(45.36, 0.01));
  });

  testWidgets('editing seeds the fields from the set being changed', (tester) async {
    await pumpLogSetSheet(tester, editing: true);

    expect(find.text('Edit set'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
  });

  testWidgets('a new set starts at the previous set reps, not at nothing', (tester) async {
    await pumpLogSetSheet(tester, defaultReps: 8);

    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('reps step by one without a keyboard', (tester) async {
    await pumpLogSetSheet(tester, defaultReps: 8);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(find.text('9'), findsOneWidget);
  });
}
