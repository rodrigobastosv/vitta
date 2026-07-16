sealed class RoutineFormPresentationEvent {}

class RoutineFormShowLoading implements RoutineFormPresentationEvent {}

class RoutineFormHideLoading implements RoutineFormPresentationEvent {}

class RoutineFormSaved implements RoutineFormPresentationEvent {}

class RoutineFormError implements RoutineFormPresentationEvent {
  const RoutineFormError({required this.message});

  final String message;
}

class RoutineFormIncomplete implements RoutineFormPresentationEvent {}
