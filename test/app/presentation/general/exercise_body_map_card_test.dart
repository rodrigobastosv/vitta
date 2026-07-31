import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/presentation/general/exercise_body_map_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../factories/entities/exercise_factory.dart';

Future<void> pumpCard(WidgetTester tester, {required Exercise exercise, Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(320, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: ExerciseBodyMapCard(exercise: exercise))),
    ),
  );
  await tester.pumpAndSettle();
}

final _benchPress = ExerciseFactory.build(secondaryMuscles: const [MuscleGroup.shoulders]);

final _chestOnly = ExerciseFactory.build(secondaryMuscles: const []);

bool _isShadeOf(Color painted, Color accent) => painted.toARGB32() & 0x00FFFFFF == accent.toARGB32() & 0x00FFFFFF;

PaintPattern paintsShadeOf(Color accent) =>
    paints..something((symbol, arguments) => symbol == #drawPath && _isShadeOf((arguments[1] as Paint).color, accent));

double paintedAlphaOf(Finder finder, Color accent) {
  double? paintedAlpha;
  expect(
    finder,
    paints
      ..something((symbol, arguments) {
        if (symbol != #drawPath) {
          return false;
        }
        final painted = (arguments[1] as Paint).color;
        if (!_isShadeOf(painted, accent)) {
          return false;
        }
        paintedAlpha = painted.a;
        return true;
      }),
  );
  return paintedAlpha!;
}

void main() {
  testWidgets('shows both views and names every region the exercise works', (tester) async {
    await pumpCard(tester, exercise: _benchPress);

    expect(find.byType(VTBodyMap), findsNWidgets(2));
    expect(find.text('Front view'), findsOneWidget);
    expect(find.text('Rear view'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Shoulders'), findsOneWidget);
  });

  testWidgets('fills a muscle it assists more faintly than one it trains directly', (tester) async {
    await pumpCard(tester, exercise: _benchPress);

    final primaryAlpha = paintedAlphaOf(find.byType(VTBodyMap).first, VTColors.bodyRegionChest);
    final secondaryAlpha = paintedAlphaOf(find.byType(VTBodyMap).first, VTColors.bodyRegionShoulders);

    expect(secondaryAlpha, lessThan(primaryAlpha));
    expect(primaryAlpha, closeTo(VTBodyMap.maxHighlightAlpha, 0.001));
  });

  testWidgets('a muscle the exercise does not work is neither named nor tinted', (tester) async {
    await pumpCard(tester, exercise: _benchPress);

    expect(find.text('Back'), findsNothing);
    expect(find.text('Legs'), findsNothing);
    expect(find.byType(VTBodyMap).first, isNot(paintsShadeOf(VTColors.bodyRegionLegs)));
    expect(find.byType(VTBodyMap).last, isNot(paintsShadeOf(VTColors.bodyRegionLegs)));
  });

  testWidgets('a chest exercise leaves the rear figure neutral, since it has no chest to show', (tester) async {
    await pumpCard(tester, exercise: _chestOnly);

    expect(find.byType(VTBodyMap).first, paintsShadeOf(VTColors.bodyRegionChest));
    expect(find.byType(VTBodyMap).last, isNot(paintsShadeOf(VTColors.bodyRegionChest)));
  });

  testWidgets('announces the muscles it works, the primary ones first', (tester) async {
    await pumpCard(tester, exercise: _benchPress);

    expect(find.bySemanticsLabel('Primary muscles: Chest. Also works: Shoulders'), findsOneWidget);
  });

  testWidgets('announces only the primary muscles when nothing assists', (tester) async {
    await pumpCard(tester, exercise: _chestOnly);

    expect(find.bySemanticsLabel('Primary muscles: Chest'), findsOneWidget);
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('fits a 320px screen in ${locale.languageCode}', (tester) async {
      await pumpCard(
        tester,
        locale: locale,
        exercise: ExerciseFactory.build(
          primaryMuscles: const [MuscleGroup.chest, MuscleGroup.quadriceps, MuscleGroup.lats],
          secondaryMuscles: const [MuscleGroup.shoulders, MuscleGroup.triceps, MuscleGroup.abdominals],
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
