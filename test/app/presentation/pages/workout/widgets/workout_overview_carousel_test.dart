import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/presentation/general/workout_body_map_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_overview_carousel.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_summary_card.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/exercise_factory.dart';
import '../../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../../factories/entities/workout_factory.dart';
import '../../../../../factories/entities/workout_set_factory.dart';

WorkoutState _stateWith({required bool completed}) => WorkoutState(
  date: DateTime(2026, 7, 30),
  workouts: [
    WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(
          exercise: ExerciseFactory.build(secondaryMuscles: const []),
          sets: [WorkoutSetFactory.build()],
          completedAt: completed ? DateTime(2026, 7, 30, 10) : null,
        ),
      ],
    ),
  ],
);

// The state that overflowed a fixed-height carousel: five metric rows plus region
// badges from every muscle group the session touched.
WorkoutState _busyState() => WorkoutState(
  date: DateTime(2026, 7, 30),
  workouts: [
    WorkoutFactory.build(
      exercises: [
        WorkoutExerciseFactory.build(
          id: 'bench',
          exercise: ExerciseFactory.build(id: 'bench', primaryMuscles: const [MuscleGroup.chest, MuscleGroup.shoulders]),
          sets: [WorkoutSetFactory.build(id: 'a'), WorkoutSetFactory.build(id: 'b')],
          completedAt: DateTime(2026, 7, 30, 10),
        ),
        WorkoutExerciseFactory.build(
          id: 'row',
          exercise: ExerciseFactory.build(id: 'row', primaryMuscles: const [MuscleGroup.lats], secondaryMuscles: const [MuscleGroup.biceps]),
          sets: [WorkoutSetFactory.build(id: 'c')],
          completedAt: DateTime(2026, 7, 30, 10),
        ),
        WorkoutExerciseFactory.build(
          id: 'squat',
          exercise: ExerciseFactory.build(id: 'squat', primaryMuscles: const [MuscleGroup.quadriceps, MuscleGroup.abdominals]),
          sets: [WorkoutSetFactory.build(id: 'd')],
          completedAt: DateTime(2026, 7, 30, 10),
        ),
        WorkoutExerciseFactory.build(
          id: 'run',
          exercise: ExerciseFactory.build(id: 'run', category: ExerciseCategory.cardio, primaryMuscles: const [MuscleGroup.calves]),
          sets: [WorkoutSetFactory.cardio(id: 'e')],
          completedAt: DateTime(2026, 7, 30, 10),
        ),
      ],
    ),
  ],
);

Finder _strip() => find.descendant(of: find.byType(WorkoutOverviewCarousel), matching: find.byType(SingleChildScrollView));

Finder _dots() => find.descendant(of: find.byType(WorkoutOverviewCarousel), matching: find.byType(AnimatedContainer));

Future<void> pumpCarousel(
  WidgetTester tester, {
  required WorkoutState state,
  Locale locale = const Locale('en'),
  UnitSystem unitSystem = UnitSystem.metric,
}) async {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(children: [WorkoutOverviewCarousel(state: state, unitSystem: unitSystem)]),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> swipeToBodyMap(WidgetTester tester) async {
  await tester.fling(_strip(), const Offset(-320, 0), 800);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('parks the body map one page to the right of the session summary', (tester) async {
    await pumpCarousel(tester, state: _stateWith(completed: true));

    expect(find.byType(WorkoutSummaryCard), findsOneWidget);
    expect(tester.getTopLeft(find.byType(WorkoutSummaryCard)).dx, 0);
    expect(tester.getTopLeft(find.byType(WorkoutBodyMapCard)).dx, 320);

    await swipeToBodyMap(tester);

    expect(tester.getTopLeft(find.byType(WorkoutBodyMapCard)).dx, 0);
    expect(find.byType(VTBodyMap), findsNWidgets(2));
  });

  testWidgets('is exactly as tall as its tallest page, so neither can overflow', (tester) async {
    await pumpCarousel(tester, state: _busyState());

    final stripHeight = tester.getSize(_strip()).height;
    expect(stripHeight, tester.getSize(find.byType(WorkoutSummaryCard)).height);
    expect(stripHeight, greaterThanOrEqualTo(tester.getSize(find.byType(WorkoutBodyMapCard)).height));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the body map counts finished exercises only', (tester) async {
    await pumpCarousel(tester, state: _stateWith(completed: false));

    expect(find.bySemanticsLabel('No muscles worked yet'), findsOneWidget);

    await pumpCarousel(tester, state: _stateWith(completed: true));

    expect(find.bySemanticsLabel('Muscles worked: Chest'), findsOneWidget);
  });

  testWidgets('says which page is showing', (tester) async {
    await pumpCarousel(tester, state: _stateWith(completed: true));

    expect(_dots(), findsNWidgets(2));
    expect(tester.getSize(_dots().first).width, greaterThan(tester.getSize(_dots().last).width));

    await swipeToBodyMap(tester);

    expect(tester.getSize(_dots().last).width, greaterThan(tester.getSize(_dots().first).width));
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    for (final unitSystem in UnitSystem.values) {
      testWidgets('neither page overflows at 320px in ${locale.languageCode} on ${unitSystem.name}', (tester) async {
        await pumpCarousel(tester, locale: locale, unitSystem: unitSystem, state: _busyState());
        expect(tester.takeException(), isNull);

        await swipeToBodyMap(tester);
        expect(tester.takeException(), isNull);

        await pumpCarousel(tester, locale: locale, unitSystem: unitSystem, state: _stateWith(completed: false));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
