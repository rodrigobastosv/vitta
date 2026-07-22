import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/workout_exercise_factory.dart';
import '../../../../factories/entities/workout_set_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

RestTimerCubit buildRestTimer() {
  final getRestDurationUseCase = MockGetRestDurationUseCase();
  final saveRestDurationUseCase = MockSaveRestDurationUseCase();
  when(getRestDurationUseCase.call).thenReturn(const Duration(seconds: 90));
  when(() => saveRestDurationUseCase(any())).thenAnswer((_) async {});
  return RestTimerCubit(getRestDurationUseCase: getRestDurationUseCase, saveRestDurationUseCase: saveRestDurationUseCase);
}

Future<RestTimerCubit> pumpExerciseWorkoutPage(WidgetTester tester, {required WorkoutExercise workoutExercise}) async {
  final setCompleted = MockSetWorkoutExerciseCompletedUseCase();
  when(
    () => setCompleted(workoutExerciseId: any(named: 'workoutExerciseId'), completed: any(named: 'completed')),
  ).thenAnswer((_) async => Success(workoutExercise));
  if (G.isRegistered<ExerciseWorkoutCubit>()) {
    G.unregister<ExerciseWorkoutCubit>();
  }
  G.registerFactoryParam<ExerciseWorkoutCubit, ExerciseWorkoutExtra, void>(
    (extra, _) => ExerciseWorkoutCubit(
      extra: extra,
      logSetUseCase: MockLogSetUseCase(),
      updateSetUseCase: MockUpdateSetUseCase(),
      deleteSetUseCase: MockDeleteSetUseCase(),
      setWorkoutExerciseCompletedUseCase: setCompleted,
    ),
  );
  addTearDown(() => G.unregister<ExerciseWorkoutCubit>());

  final timer = buildRestTimer();
  addTearDown(timer.close);
  await tester.pumpWidget(
    BlocProvider.value(
      value: timer,
      child: MaterialApp.router(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Finishing pops the page, so it needs somewhere to pop back to - a lone
        // route would assert on an empty stack before the timer could be read.
        routerConfig: GoRouter(
          initialLocation: '/exercise',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(body: Text('workout day')),
              routes: [
                GoRoute(
                  path: 'exercise',
                  builder: (context, state) =>
                      ExerciseWorkoutPage(extra: ExerciseWorkoutExtra(workoutExercise: workoutExercise, unitSystem: UnitSystem.metric)),
                ),
              ],
            ),
          ],
        ),
        builder: (context, child) => LoaderOverlay(child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return timer;
}

void main() {
  setUpAll(() => registerFallbackValue(Duration.zero));

  testWidgets('finishing an exercise ends its rest, so it does not run on into the next one', (tester) async {
    final workoutExercise = WorkoutExerciseFactory.build(sets: [WorkoutSetFactory.build()]);
    final timer = await pumpExerciseWorkoutPage(tester, workoutExercise: workoutExercise);

    timer.start(label: 'Incline Dumbbell Press');
    await tester.pump();
    expect(timer.state.isRunning, isTrue);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(timer.state.isRunning, isFalse);
  });
}
