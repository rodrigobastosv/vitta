import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression_point.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

Future<void> pumpProgressionPage(WidgetTester tester, {required ExerciseProgression progression}) async {
  final getExerciseProgressionUseCase = MockGetExerciseProgressionUseCase();
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(() => getExerciseProgressionUseCase(exerciseId: any(named: 'exerciseId'))).thenAnswer((_) async => Success(progression));
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
  if (G.isRegistered<ExerciseProgressionCubit>()) {
    G.unregister<ExerciseProgressionCubit>();
  }
  G.registerFactoryParam<ExerciseProgressionCubit, Exercise, void>(
    (exercise, _) => ExerciseProgressionCubit(
      getExerciseProgressionUseCase: getExerciseProgressionUseCase,
      getAppSettingsUseCase: getAppSettingsUseCase,
      exercise: exercise,
    ),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => ExerciseProgressionPage(exercise: ExerciseFactory.build()),
          ),
        ],
      ),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the records card and both trend charts when there is history', (tester) async {
    await pumpProgressionPage(
      tester,
      progression: ExerciseProgression(
        points: [
          ExerciseProgressionPoint(date: DateTime(2026, 7), sets: [WorkoutSetFactory.build(reps: 5, weightKg: 100)]),
          ExerciseProgressionPoint(date: DateTime(2026, 7, 8), sets: [WorkoutSetFactory.build(reps: 8, weightKg: 110)]),
        ],
      ),
    );

    expect(find.text('Personal records'), findsOneWidget);
    expect(find.text('Estimated 1RM'), findsOneWidget);
    expect(find.text('Heaviest load'), findsWidgets);
    expect(find.byType(VTBarChart), findsNWidgets(2));
    expect(find.text('Personal record'), findsNWidgets(2));
  });

  testWidgets('shows the empty state when the exercise has no history', (tester) async {
    await pumpProgressionPage(tester, progression: const ExerciseProgression(points: []));

    expect(find.text('No history yet'), findsOneWidget);
    expect(find.byType(VTBarChart), findsNothing);
  });
}
