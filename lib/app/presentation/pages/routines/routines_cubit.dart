import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_routine_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_routines_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/reorder_routines_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/routines/routines_presentation_event.dart';
import 'package:vitta/app/presentation/pages/routines/routines_state.dart';

class RoutinesCubit extends PresentationCubit<RoutinesState, RoutinesPresentationEvent> {
  RoutinesCubit({required this._getRoutinesUseCase, required this._deleteRoutineUseCase, required this._reorderRoutinesUseCase})
    : super(const RoutinesState(routines: [], isLoaded: false));

  final GetRoutinesUseCase _getRoutinesUseCase;
  final DeleteRoutineUseCase _deleteRoutineUseCase;
  final ReorderRoutinesUseCase _reorderRoutinesUseCase;

  @override
  void onInit() => loadRoutines();

  Future<void> loadRoutines() async {
    final routinesResult = await withLoadingOverlay(
      _getRoutinesUseCase.call,
      showOverlay: state.isLoaded,
      showLoadingEvent: RoutinesShowLoading(),
      hideLoadingEvent: RoutinesHideLoading(),
    );
    routinesResult.when((error) => emitPresentation(RoutinesError(message: error.message)), (value) => emit(RoutinesState(routines: value)));
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> deleteRoutine({required String routineId}) async {
    final deletedResult = await _deleteRoutineUseCase(routineId: routineId);
    await deletedResult.when((error) => Future.sync(() => emitPresentation(RoutinesError(message: error.message))), (_) {
      Log.action(.workoutRoutineDeleted);
      return loadRoutines();
    });
  }

  Future<void> reorderRoutines({required int oldIndex, required int newIndex}) async {
    final previous = state.routines;
    final reordered = [...state.routines];
    reordered.insert(newIndex, reordered.removeAt(oldIndex));
    emit(state.copyWith(routines: reordered));

    final reorderedResult = await _reorderRoutinesUseCase(orderedRoutineIds: [for (final routine in reordered) routine.id]);
    await reorderedResult.when(
      (error) {
        emit(state.copyWith(routines: previous));
        return Future.sync(() => emitPresentation(RoutinesError(message: error.message)));
      },
      (_) {
        Log.action(.workoutRoutinesReordered);
        return Future<void>.value();
      },
    );
  }
}
