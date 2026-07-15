import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/routine_draft.dart';
import 'package:vitta/app/domain/workout/use_cases/save_routine_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_state.dart';

class RoutineFormCubit extends PresentationCubit<RoutineFormState, RoutineFormPresentationEvent> {
  RoutineFormCubit({required this._saveRoutineUseCase, Routine? routine})
    : super(
        RoutineFormState(draft: routine == null ? const RoutineDraft() : RoutineDraft.fromRoutine(routine), routine: routine),
      );

  final SaveRoutineUseCase _saveRoutineUseCase;

  void nameChanged(String name) => emit(state.copyWith(draft: state.draft.copyWith(name: name)));

  /// A routine is a list of *distinct* exercises - repeating one is what sets
  /// are for, not a second entry. Adding one already in the list is a no-op
  /// rather than an error: the user picked something they already have, and
  /// the list already says so.
  void addExercise(Exercise exercise) {
    if (state.draft.exercises.any((existing) => existing.id == exercise.id)) {
      return;
    }
    emit(state.copyWith(draft: state.draft.copyWith(exercises: [...state.draft.exercises, exercise])));
  }

  void removeExerciseAt(int index) {
    final exercises = [...state.draft.exercises]..removeAt(index);
    emit(state.copyWith(draft: state.draft.copyWith(exercises: exercises)));
  }

  /// Reordering is the whole point of a routine's exercise list - it's the order
  /// they'll be performed in, and it becomes each exercise's `position`.
  ///
  /// `newIndex` is the destination *after* the item is removed, which is what
  /// ReorderableListView's onReorderItem already accounts for - don't re-adjust
  /// it here, or a downward drag lands one slot short.
  void reorderExercise({required int oldIndex, required int newIndex}) {
    final exercises = [...state.draft.exercises];
    exercises.insert(newIndex, exercises.removeAt(oldIndex));
    emit(state.copyWith(draft: state.draft.copyWith(exercises: exercises)));
  }

  Future<void> save() async {
    if (!state.draft.isComplete) {
      emitPresentation(RoutineFormIncomplete());
      return;
    }
    emitPresentation(RoutineFormShowLoading());
    final savedResult = await _saveRoutineUseCase(draft: state.draft, routine: state.routine);
    emitPresentation(RoutineFormHideLoading());
    savedResult.when((error) => emitPresentation(RoutineFormError(message: error.message)), (_) {
      Log.action(state.isEditing ? 'workout_routine_updated' : 'workout_routine_created', data: {
        'exercises': state.draft.exercises.length,
      });
      emitPresentation(RoutineFormSaved());
    });
  }
}
