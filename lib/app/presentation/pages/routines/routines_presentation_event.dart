sealed class RoutinesPresentationEvent {}

class RoutinesShowLoading implements RoutinesPresentationEvent {}

class RoutinesHideLoading implements RoutinesPresentationEvent {}

class RoutinesError implements RoutinesPresentationEvent {
  const RoutinesError({required this.message});

  final String message;
}
