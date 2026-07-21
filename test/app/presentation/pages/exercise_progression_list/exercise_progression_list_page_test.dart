import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_page.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/widgets/logged_exercise_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/exercise_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

Future<void> pumpListPage(WidgetTester tester, {required List<Exercise> exercises}) async {
  final getLoggedExercisesUseCase = MockGetLoggedExercisesUseCase();
  when(getLoggedExercisesUseCase.call).thenAnswer((_) async => Success(exercises));
  if (G.isRegistered<ExerciseProgressionListCubit>()) {
    G.unregister<ExerciseProgressionListCubit>();
  }
  G.registerFactory<ExerciseProgressionListCubit>(() => ExerciseProgressionListCubit(getLoggedExercisesUseCase: getLoggedExercisesUseCase));

  await tester.pumpWidget(
    MaterialApp.router(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (context, state) => const ExerciseProgressionListPage())],
      ),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists a tile per logged exercise', (tester) async {
    await pumpListPage(
      tester,
      exercises: [
        ExerciseFactory.build(id: 'a', names: const {'en': 'Bench Press'}),
        ExerciseFactory.build(id: 'b', names: const {'en': 'Deadlift'}),
      ],
    );

    expect(find.byType(LoggedExerciseTile), findsNWidgets(2));
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Deadlift'), findsOneWidget);
  });

  testWidgets('shows the empty state when nothing has been logged', (tester) async {
    await pumpListPage(tester, exercises: const []);

    expect(find.text('No exercises logged yet'), findsOneWidget);
    expect(find.byType(LoggedExerciseTile), findsNothing);
  });
}
