import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/session_progress_row.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/workout_summary_exercise_row.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_extra.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

Future<void> pumpSummary(
  WidgetTester tester, {
  List<Workout>? workouts,
  Map<String, List<WorkoutSet>> lastSetsByExercise = const {},
  double? latestBodyWeightKg = 80,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(320, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WorkoutSummaryPage(
        extra: WorkoutSummaryExtra(
          date: DateTime(2026, 7, 20),
          workouts:
              workouts ??
              [
                WorkoutFactory.build(
                  exercises: [
                    WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()], completedAt: DateTime(2026, 7, 20)),
                  ],
                ),
              ],
          lastSetsByExercise: lastSetsByExercise,
          latestBodyWeightKg: latestBodyWeightKg,
          unitSystem: UnitSystem.metric,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('celebrates on arrival, since this is the payoff screen', (tester) async {
    await pumpSummary(tester);

    expect(find.byKey(VTCelebration.burstKey), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('leads with the calorie estimate and lists what was done', (tester) async {
    await pumpSummary(tester);
    await tester.pumpAndSettle();

    expect(find.text('Estimated burn'), findsOneWidget);
    expect(find.byType(WorkoutSummaryExerciseRow), findsOneWidget);
  });

  testWidgets('reports one row per exercise against the last session', (tester) async {
    await pumpSummary(
      tester,
      workouts: [
        WorkoutFactory.build(
          exercises: [
            WorkoutExerciseFactory.build(id: 'we-1', sets: [WorkoutSetFactory.build(weightKg: 60)], completedAt: DateTime(2026, 7, 20)),
          ],
        ),
      ],
      lastSetsByExercise: {
        'exercise-1': [WorkoutSetFactory.build(id: 'old', weightKg: 50)],
      },
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionProgressRow), findsOneWidget);
    expect(find.text('1 exercise moved up'), findsOneWidget);
  });

  testWidgets('an exercise with no history reads as a first time', (tester) async {
    await pumpSummary(tester);
    await tester.pumpAndSettle();

    expect(find.text('First time'), findsOneWidget);
    expect(find.text('Nothing moved up this time'), findsOneWidget);
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('fits a 320px screen in ${locale.languageCode}', (tester) async {
      await pumpSummary(tester, locale: locale, latestBodyWeightKg: null);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
