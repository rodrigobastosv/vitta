import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_extra.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';

WorkoutState finishedState() => WorkoutState(
  date: DateTime(2026, 7, 15),
  workouts: [
    WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(
          id: 'we-0',
          exercise: ExerciseFactory.build(id: 'ex-0', names: const {'en': 'Bench Press', 'pt': 'Supino'}),
          completedAt: DateTime(2026, 7, 15),
          sets: [WorkoutSetFactory.build(id: 'set-0')],
        ),
        WorkoutExerciseFactory.build(
          id: 'we-1',
          position: 1,
          exercise: ExerciseFactory.build(id: 'ex-1', names: const {'en': 'Squat', 'pt': 'Agachamento'}),
          completedAt: DateTime(2026, 7, 15),
          sets: [WorkoutSetFactory.build(reps: 8)],
        ),
      ],
    ),
  ],
);

Future<void> pumpSummaryPage(WidgetTester tester, {bool celebrate = false, Locale locale = const Locale('en'), Size size = const Size(320, 900)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WorkoutSummaryPage(
        extra: WorkoutSummaryExtra(state: finishedState(), unitSystem: UnitSystem.metric, celebrate: celebrate),
      ),
    ),
  );
}

void main() {
  testWidgets('leads with the finished hero and lists every exercise trained', (tester) async {
    await pumpSummaryPage(tester, size: const Size(400, 1600));
    await tester.pumpAndSettle();

    expect(find.text('Workout done'), findsOneWidget);
    expect(find.text('What you trained'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
  });

  testWidgets('celebrates on arrival only when the workout was just finished', (tester) async {
    await pumpSummaryPage(tester, celebrate: true);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(VTCelebration.burstKey), findsOneWidget);
  });

  testWidgets('reopening a past day is a look back, not an achievement', (tester) async {
    await pumpSummaryPage(tester);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(VTCelebration.burstKey), findsNothing);
  });

  testWidgets('fits a narrow screen in both locales', (tester) async {
    for (final locale in const [Locale('en'), Locale('pt')]) {
      await pumpSummaryPage(tester, locale: locale);
      await tester.pump();

      expect(tester.takeException(), isNull);
    }
  });
}
