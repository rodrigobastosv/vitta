import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_exercise_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_exercise_thumbnail.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_set_row.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/exercise_factory.dart';
import '../../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../../factories/entities/workout_set_factory.dart';

Future<void> pumpCard(
  WidgetTester tester, {
  required WorkoutExercise workoutExercise,
  VoidCallback? onRepeatSet,
  ValueChanged<bool>? onToggleCompleted,
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: WorkoutExerciseCard(
        workoutExercise: workoutExercise,
        unitSystem: .metric,
        onAddSet: () {},
        onRepeatSet: onRepeatSet,
        onToggleCompleted: onToggleCompleted,
      ),
    ),
  ),
);

void main() {
  testWidgets('a cardio exercise is one effort - once it is logged there is nothing to add or repeat', (tester) async {
    final treadmill = ExerciseFactory.build(names: const {'en': 'Treadmill', 'pt': 'Esteira'}, category: .cardio);

    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(exercise: treadmill),
      onRepeatSet: () {},
    );

    expect(find.text('Log effort'), findsOneWidget);
    expect(find.text('Add set'), findsNothing);

    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(exercise: treadmill, sets: [WorkoutSetFactory.cardio()]),
      onRepeatSet: () {},
    );

    expect(find.text('Log effort'), findsNothing);
    expect(find.text('Repeat set'), findsNothing);
  });

  testWidgets('a cardio effort is not numbered, since there is never a second one', (tester) async {
    final treadmill = ExerciseFactory.build(category: .cardio);

    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(exercise: treadmill, sets: [WorkoutSetFactory.cardio()]),
    );

    expect(tester.widget<WorkoutSetRow>(find.byType(WorkoutSetRow)).position, isNull);

    await pumpCard(tester, workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]));

    expect(tester.widget<WorkoutSetRow>(find.byType(WorkoutSetRow)).position, 1);
  });

  testWidgets('offers Repeat only once there is a set to repeat', (tester) async {
    await pumpCard(tester, workoutExercise: WorkoutExerciseFactory.build(), onRepeatSet: () {});

    expect(find.text('Repeat set'), findsNothing);

    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
      onRepeatSet: () {},
    );

    expect(find.text('Repeat set'), findsOneWidget);
  });

  testWidgets('a finished exercise collapses its working surface', (tester) async {
    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()], completedAt: DateTime(2026, 7, 20)),
      onToggleCompleted: (_) {},
    );

    expect(find.byType(WorkoutSetRow), findsNothing);
    expect(find.text('Add set'), findsNothing);
  });

  testWidgets('a collapsed exercise still says what was done, so tidying is not losing', (tester) async {
    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(
        sets: [
          WorkoutSetFactory.build(id: 's1'),
          WorkoutSetFactory.build(id: 's2'),
        ],
        completedAt: DateTime(2026, 7, 20),
      ),
      onToggleCompleted: (_) {},
    );

    expect(find.text('Incline Dumbbell Press'), findsOneWidget);
    expect(find.text('2 sets done'), findsOneWidget);
  });

  testWidgets('an unfinished exercise shows its sets and can be worked from', (tester) async {
    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]),
      onToggleCompleted: (_) {},
    );

    expect(find.byType(WorkoutSetRow), findsOneWidget);
    expect(find.text('Add set'), findsOneWidget);
  });

  testWidgets('a finished exercise is stamped done, and stays legible while saying it', (tester) async {
    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()], completedAt: DateTime(2026, 7, 20)),
      onToggleCompleted: (_) {},
    );

    expect(tester.widget<WorkoutExerciseThumbnail>(find.byType(WorkoutExerciseThumbnail)).isCompleted, isTrue);
    expect(tester.widget<Text>(find.text('1 set done')).style?.color, isNot(Colors.transparent));
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('an unfinished exercise carries no done stamp', (tester) async {
    await pumpCard(tester, workoutExercise: WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]));

    expect(tester.widget<WorkoutExerciseThumbnail>(find.byType(WorkoutExerciseThumbnail)).isCompleted, isFalse);
  });

  testWidgets('marking done is reversible - a finished card offers Reopen', (tester) async {
    bool? requested;
    await pumpCard(
      tester,
      workoutExercise: WorkoutExerciseFactory.build(completedAt: DateTime(2026, 7, 20)),
      onToggleCompleted: (completed) => requested = completed,
    );

    await tester.tap(find.byTooltip('Reopen'));

    expect(requested, isFalse);
  });
}
