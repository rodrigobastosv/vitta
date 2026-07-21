import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_drag_handle.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_extra.dart';
import 'package:vitta/app/presentation/pages/routines/routines_cubit.dart';
import 'package:vitta/app/presentation/pages/routines/routines_presentation_event.dart';
import 'package:vitta/app/presentation/pages/routines/routines_state.dart';
import 'package:vitta/app/presentation/pages/routines/widgets/routine_tile.dart';

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<RoutinesCubit, RoutinesState, RoutinesPresentationEvent>(
      onPresentation: (context, event) => switch (event) {
        RoutinesShowLoading() => context.showLoading(),
        RoutinesHideLoading() => context.hideLoading(),
        RoutinesError(:final message) => context.showErrorToast(message: message, onRetry: context.read<RoutinesCubit>().loadRoutines),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.workoutRoutinesTitle)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(context, cubit),
          icon: const Icon(Icons.add),
          label: Text(l10n.workoutRoutineNewAction),
        ),
        body: state.routines.isEmpty
            ? VTEmptyState(
                icon: Icons.repeat,
                title: l10n.workoutRoutinesEmptyTitle,
                message: l10n.workoutRoutinesEmptyMessage,
                actionLabel: l10n.workoutRoutineNewAction,
                actionIcon: Icons.add,
                onAction: () => _openForm(context, cubit),
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, VTSpacing.xxl * 2),
                itemCount: state.routines.length,
                buildDefaultDragHandles: false,
                onReorderStart: (_) => VTHaptics.drag(),
                onReorderEnd: (_) => VTHaptics.drag(),
                onReorderItem: (oldIndex, newIndex) => cubit.reorderRoutines(oldIndex: oldIndex, newIndex: newIndex),
                itemBuilder: (context, index) {
                  final routine = state.routines[index];
                  return Padding(
                    key: ValueKey(routine.id),
                    padding: const EdgeInsets.only(bottom: VTSpacing.s),
                    child: RoutineTile(
                      routine: routine,
                      onTap: () => _openForm(context, cubit, routineIndex: index),
                      onDelete: () => cubit.deleteRoutine(routineId: routine.id),
                      dragHandle: ReorderableDragStartListener(index: index, child: const VTDragHandle()),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, RoutinesCubit cubit, {int? routineIndex}) async {
    final routine = routineIndex == null ? null : cubit.state.routines[routineIndex];
    final saved = await context.pushRoute<bool>(.routineForm, extra: RoutineFormExtra(routine: routine));
    if (saved ?? false) {
      await cubit.loadRoutines();
    }
  }
}
