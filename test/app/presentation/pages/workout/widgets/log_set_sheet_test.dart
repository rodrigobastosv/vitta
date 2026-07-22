import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/labelled_field.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/log_set_sheet.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/set_prefill.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/workout_set_factory.dart';

Future<void> pumpLogSetSheet(
  WidgetTester tester, {
  UnitSystem unitSystem = UnitSystem.metric,
  Future<Result<VTError, void>> Function({required SetInput input})? onSubmit,
  bool editing = false,
  bool isCardio = false,
  int? defaultReps,
  SetPrefill prefill = SetPrefill.none,
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: LogSetSheet(
        unitSystem: unitSystem,
        isCardio: isCardio,
        set: editing ? (isCardio ? WorkoutSetFactory.cardio(durationSeconds: 1530) : WorkoutSetFactory.build(reps: 8, weightKg: 60)) : null,
        defaultReps: defaultReps,
        prefill: prefill,
        onSubmit: onSubmit ?? ({required input}) async => const Success(null),
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
      onSubmit: ({required input}) async {
        submittedWeight = input.weightKg;
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
      onSubmit: ({required input}) async {
        submittedWeight = input.weightKg;
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

  testWidgets('the hint names the last set when that is where the numbers came from', (tester) async {
    await pumpLogSetSheet(tester, defaultReps: 8, prefill: SetPrefill.lastSet);

    expect(find.text('Prefilled from your last set'), findsOneWidget);
    expect(find.text('Prefilled with your latest body weight'), findsNothing);
  });

  testWidgets('the hint still names body weight on a bodyweight exercise with no sets yet', (tester) async {
    await pumpLogSetSheet(tester, prefill: SetPrefill.bodyWeight);

    expect(find.text('Prefilled with your latest body weight'), findsOneWidget);
  });

  testWidgets('reps and load line up, so the row does not read as two different controls', (tester) async {
    await pumpLogSetSheet(tester, defaultReps: 8);

    final fields = find.byType(LabelledField);
    final repsTop = tester.getTopLeft(fields.first).dy;
    final loadTop = tester.getTopLeft(fields.last).dy;

    expect((repsTop - loadTop).abs(), lessThan(4), reason: 'the reps stepper and the load field share a top edge');
  });

  testWidgets('a cardio exercise asks for duration and distance, not reps and load', (tester) async {
    await pumpLogSetSheet(tester, isCardio: true);

    expect(find.text('Distance (km)'), findsOneWidget);
    expect(find.text('Load (kg)'), findsNothing);
    expect(find.text('Reps'), findsNothing);
  });

  testWidgets('a cardio set submits duration in seconds and distance in meters', (tester) async {
    SetInput? submitted;
    await pumpLogSetSheet(
      tester,
      isCardio: true,
      onSubmit: ({required input}) async {
        submitted = input;
        return const Success(null);
      },
    );

    await tester.enterText(find.byType(TextField).at(0), '25');
    await tester.enterText(find.byType(TextField).at(1), '30');
    await tester.enterText(find.byType(TextField).at(2), '5');
    await tester.tap(find.text('Save set'));
    await tester.pump();

    expect(submitted?.durationSeconds, 1530);
    expect(submitted?.distanceMeters, 5000);
    expect(submitted?.reps, isNull);
  });

  testWidgets('a cardio set with no duration is rejected', (tester) async {
    SetInput? submitted;
    await pumpLogSetSheet(
      tester,
      isCardio: true,
      onSubmit: ({required input}) async {
        submitted = input;
        return const Success(null);
      },
    );

    await tester.tap(find.text('Save set'));
    await tester.pump();

    expect(submitted, isNull);
    expect(find.text('Enter how long it lasted.'), findsOneWidget);
  });

  testWidgets('distance is optional on a cardio set', (tester) async {
    SetInput? submitted;
    await pumpLogSetSheet(
      tester,
      isCardio: true,
      onSubmit: ({required input}) async {
        submitted = input;
        return const Success(null);
      },
    );

    await tester.enterText(find.byType(TextField).at(0), '20');
    await tester.tap(find.text('Save set'));
    await tester.pump();

    expect(submitted?.durationSeconds, 1200);
    expect(submitted?.distanceMeters, isNull);
  });
}
