import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_summary_card.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../../factories/entities/workout_factory.dart';
import '../../../../../factories/entities/workout_set_factory.dart';

Future<void> pumpSummary(WidgetTester tester, {required WorkoutState state, Locale locale = const Locale('en')}) {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WorkoutSummaryCard(state: state, unitSystem: .metric),
      ),
    ),
  );
}

WorkoutState buildState({required int exercises, required int completed}) => WorkoutState(
  date: DateTime(2026, 7, 15),
  workouts: [
    WorkoutFactory.build(
      exercises: [
        for (var index = 0; index < exercises; index++)
          WorkoutExerciseFactory.build(
            id: 'we-$index',
            position: index,
            completedAt: index < completed ? DateTime(2026, 7, 15) : null,
            sets: [WorkoutSetFactory.build(id: 'set-$index')],
          ),
      ],
    ),
  ],
);

void main() {
  testWidgets('the ring counts finished exercises against the day and says what is left', (tester) async {
    await pumpSummary(tester, state: buildState(exercises: 5, completed: 2));

    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('3 to go'), findsOneWidget);
  });

  testWidgets('a finished day says so rather than counting down to zero', (tester) async {
    await pumpSummary(tester, state: buildState(exercises: 3, completed: 3));

    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('All done'), findsOneWidget);
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('lays out on a narrow phone in ${locale.languageCode}', (tester) async {
      await pumpSummary(tester, state: buildState(exercises: 12, completed: 10), locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
