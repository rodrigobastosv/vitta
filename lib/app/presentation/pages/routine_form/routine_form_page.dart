import 'package:flutter/material.dart';
import 'package:vitta/app/core/error/error_dialog_extensions.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_drag_handle.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_cubit.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_state.dart';
import 'package:vitta/app/presentation/pages/routine_form/widgets/routine_exercise_tile.dart';
import 'package:vitta/app/presentation/pages/routine_form/widgets/routine_name_field.dart';

class RoutineFormPage extends StatelessWidget {
  const RoutineFormPage({this.routine, super.key});

  final Routine? routine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<RoutineFormCubit, RoutineFormState, RoutineFormPresentationEvent>(
      cubitParam: routine,
      onPresentation: (context, event) => switch (event) {
        RoutineFormShowLoading() => context.showLoading(),
        RoutineFormHideLoading() => context.hideLoading(),
        RoutineFormSaved() => Navigator.of(context).pop(true),
        RoutineFormIncomplete() => context.showErrorDialog(message: l10n.workoutRoutineIncompleteMessage),
        RoutineFormError(:final message) => context.showErrorDialog(message: message),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(state.isEditing ? state.routine!.name : l10n.workoutRoutineNewAction)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, VTSpacing.s),
              child: RoutineNameField(initialName: state.draft.name, onChanged: cubit.nameChanged),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(l10n.workoutRoutineExercisesTitle, style: VTTextStyles.overline(context)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.workoutRoutineAddExerciseAction),
                    onPressed: () => _addExercise(context, cubit),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(VTSpacing.m, 0, VTSpacing.m, VTSpacing.m),
                itemCount: state.draft.exercises.length,
                buildDefaultDragHandles: false,
                // onReorderItem, not the deprecated onReorder: it hands back a
                // newIndex already adjusted for the removed item, so the cubit
                // takes a final index rather than re-deriving one.
                onReorderItem: (oldIndex, newIndex) => cubit.reorderExercise(oldIndex: oldIndex, newIndex: newIndex),
                itemBuilder: (context, index) => Padding(
                  // Keyed by exercise id alone, never the index: a
                  // ReorderableListView needs a key that stays with the item
                  // across a move, and an index-based key changes for every
                  // row the moment one is dragged, so nothing sticks. Safe
                  // because a routine holds distinct exercises (see
                  // RoutineFormCubit.addExercise).
                  key: ValueKey(state.draft.exercises[index].id),
                  padding: const EdgeInsets.only(bottom: VTSpacing.s),
                  child: RoutineExerciseTile(
                    exercise: state.draft.exercises[index],
                    position: index + 1,
                    onRemove: () => cubit.removeExerciseAt(index),
                    dragHandle: ReorderableDragStartListener(index: index, child: const VTDragHandle()),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(VTSpacing.m),
                child: VTPrimaryButton(label: l10n.workoutRoutineSaveAction, onPressed: cubit.save),
              ),
            ),
            const VTGap.xs(),
          ],
        ),
      ),
    );
  }

  Future<void> _addExercise(BuildContext context, RoutineFormCubit cubit) async {
    final exercise = await context.pushRoute<Exercise>(.exerciseSearch);
    if (exercise != null) {
      cubit.addExercise(exercise);
    }
  }
}
