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
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_cubit.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

DailyWorkout buildTrainedDay(DateTime day) => DailyWorkout(
  date: day,
  workouts: [
    WorkoutFactory.build(
      performedDate: day,
      exercises: [
        WorkoutExerciseFactory.build(
          exercise: ExerciseFactory.build(primaryMuscles: const [MuscleGroup.quadriceps]),
          sets: [WorkoutSetFactory.build(reps: 5, weightKg: 100)],
        ),
      ],
    ),
  ],
);

Future<void> pumpHistoryPage(WidgetTester tester, {Map<DateTime, DailyWorkout> workoutsByDate = const {}}) async {
  final getDailyWorkoutsInRangeUseCase = MockGetDailyWorkoutsInRangeUseCase();
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(() => getDailyWorkoutsInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(workoutsByDate));
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
  await tester.binding.setSurfaceSize(const Size(500, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  if (G.isRegistered<WorkoutHistoryCubit>()) {
    G.unregister<WorkoutHistoryCubit>();
  }
  G.registerFactory<WorkoutHistoryCubit>(
    () => WorkoutHistoryCubit(getDailyWorkoutsInRangeUseCase: getDailyWorkoutsInRangeUseCase, getAppSettingsUseCase: getAppSettingsUseCase),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(routes: [GoRoute(path: '/', builder: (context, state) => const WorkoutHistoryPage())]),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2026)));

  testWidgets('shows the calendar and the trends section', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await pumpHistoryPage(tester, workoutsByDate: {today: buildTrainedDay(today)});

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Trends'), findsOneWidget);
    expect(find.text('Volume per session'), findsOneWidget);
    expect(find.text('Volume by muscle group'), findsOneWidget);
  });

  testWidgets('invites a first session instead of showing an empty calendar and flat charts', (tester) async {
    await pumpHistoryPage(tester);

    expect(find.text('No sessions logged yet'), findsOneWidget);
    expect(find.text('Start a workout'), findsOneWidget);
    expect(find.text('Trends'), findsNothing);
  });

  testWidgets('renders the volume chart and muscle split once there is a trained day', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await pumpHistoryPage(tester, workoutsByDate: {today: buildTrainedDay(today)});

    expect(find.byType(VTBarChart), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);
  });
}
