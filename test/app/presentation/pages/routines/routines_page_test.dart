import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/general/vt_drag_handle.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/routines/routines_cubit.dart';
import 'package:vitta/app/presentation/pages/routines/routines_state.dart';
import 'package:vitta/app/presentation/pages/routines/widgets/routine_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/routine_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

Future<void> pumpRoutinesPage(WidgetTester tester, {required RoutinesCubit cubit}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<RoutinesCubit>.value(
      value: cubit,
      child: BlocBuilder<RoutinesCubit, RoutinesState>(
        builder: (context, state) => Scaffold(
          body: ReorderableListView.builder(
            itemCount: state.routines.length,
            buildDefaultDragHandles: false,
            onReorderItem: (oldIndex, newIndex) => cubit.reorderRoutines(oldIndex: oldIndex, newIndex: newIndex),
            itemBuilder: (context, index) => RoutineTile(
              key: ValueKey(state.routines[index].id),
              routine: state.routines[index],
              onTap: () {},
              dragHandle: ReorderableDragStartListener(index: index, child: const VTDragHandle()),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  setUpAll(() => registerFallbackValue(<String, Object?>{}));

  testWidgets('every routine exposes a drag handle, so the list reads as reorderable', (tester) async {
    final getRoutinesUseCase = MockGetRoutinesUseCase();
    when(getRoutinesUseCase.call).thenAnswer((_) async => Success(RoutineFactory.buildCycle()));
    final cubit = CubitsFactories.buildRoutinesCubit(getRoutinesUseCase: getRoutinesUseCase);
    await cubit.loadRoutines();

    await pumpRoutinesPage(tester, cubit: cubit);
    await tester.pumpAndSettle();

    expect(find.byType(VTDragHandle), findsNWidgets(3));
  });

  testWidgets('dragging a routine by its handle reorders the cycle', (tester) async {
    useMockLog();
    final getRoutinesUseCase = MockGetRoutinesUseCase();
    final reorderRoutinesUseCase = MockReorderRoutinesUseCase();
    when(getRoutinesUseCase.call).thenAnswer((_) async => Success(RoutineFactory.buildCycle()));
    when(() => reorderRoutinesUseCase(orderedRoutineIds: any(named: 'orderedRoutineIds'))).thenAnswer((_) async => const Success(null));
    final cubit = CubitsFactories.buildRoutinesCubit(
      getRoutinesUseCase: getRoutinesUseCase,
      reorderRoutinesUseCase: reorderRoutinesUseCase,
    );
    await cubit.loadRoutines();

    await pumpRoutinesPage(tester, cubit: cubit);
    await tester.pumpAndSettle();

    final tileHeight = tester.getSize(find.byType(RoutineTile).first).height;
    final gesture = await tester.startGesture(tester.getCenter(find.byType(VTDragHandle).first));
    await tester.pump(kLongPressTimeout);
    for (var moved = 0.0; moved < tileHeight + 1; moved += 10) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect([for (final routine in cubit.state.routines) routine.id], ['routine-b', 'routine-a', 'routine-c']);
  });
}
