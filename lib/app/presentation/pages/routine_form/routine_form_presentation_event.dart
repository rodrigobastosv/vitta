sealed class RoutineFormPresentationEvent {}

class RoutineFormShowLoading implements RoutineFormPresentationEvent {}

class RoutineFormHideLoading implements RoutineFormPresentationEvent {}

class RoutineFormSaved implements RoutineFormPresentationEvent {}

class RoutineFormError implements RoutineFormPresentationEvent {
  const RoutineFormError({required this.message});

  final String message;
}

/// The form is missing a name or has no exercises. A separate event from
/// RoutineFormError because it carries no message: the page owns the wording,
/// as CustomFoodPage does for its incomplete-form case.
class RoutineFormIncomplete implements RoutineFormPresentationEvent {}
