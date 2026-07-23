import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_workout_hero.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/exercise_factory.dart';
import '../../../../../factories/entities/routine_factory.dart';
import '../../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../../factories/entities/workout_set_factory.dart';

Future<void> pumpHero(
  WidgetTester tester, {
  int completedExercises = 0,
  int totalExercises = 0,
  List<WorkoutExercise> remainingExercises = const [],
  Routine? nextRoutine,
  Locale locale = const Locale('en'),
}) {
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
        body: HomeWorkoutHero(
          completedExercises: completedExercises,
          totalExercises: totalExercises,
          remainingExercises: remainingExercises,
          nextRoutine: nextRoutine,
          onTap: () {},
        ),
      ),
    ),
  );
}

WorkoutExercise buildRemaining(String name, {int sets = 0}) => WorkoutExerciseFactory.build(
  id: 'we-$name',
  exercise: ExerciseFactory.build(id: name, names: {'en': name}),
  sets: [for (var index = 0; index < sets; index++) WorkoutSetFactory.build(id: '$name-set-$index')],
);

void main() {
  testWidgets('a day with nothing logged says the session is pending and names the routine that is up next', (tester) async {
    await pumpHero(tester, nextRoutine: RoutineFactory.build(name: 'Workout B'));

    expect(find.text('Not started yet'), findsOneWidget);
    expect(find.text('Next up: Workout B'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('a session under way lists what is still left to do', (tester) async {
    await pumpHero(
      tester,
      completedExercises: 1,
      totalExercises: 3,
      remainingExercises: [buildRemaining('Bench Press', sets: 2), buildRemaining('Squat')],
    );

    expect(find.text('2 exercises left'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('2 sets'), findsOneWidget);
  });

  testWidgets('a finished session says so rather than counting what is left', (tester) async {
    await pumpHero(tester, completedExercises: 3, totalExercises: 3);

    expect(find.text('Session done'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
  });

  testWidgets('only the first exercises are listed, the rest are counted', (tester) async {
    await pumpHero(
      tester,
      totalExercises: 5,
      remainingExercises: [
        buildRemaining('One'),
        buildRemaining('Two'),
        buildRemaining('Three'),
        buildRemaining('Four'),
        buildRemaining('Five'),
      ],
    );

    expect(find.text('Four'), findsNothing);
    expect(find.text('+2 more'), findsOneWidget);
  });
}
