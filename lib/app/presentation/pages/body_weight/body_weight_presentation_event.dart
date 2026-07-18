sealed class BodyWeightPresentationEvent {}

class BodyWeightShowLoading implements BodyWeightPresentationEvent {}

class BodyWeightHideLoading implements BodyWeightPresentationEvent {}

class BodyWeightError implements BodyWeightPresentationEvent {
  const BodyWeightError({required this.message});

  final String message;
}

class BodyWeightLogged implements BodyWeightPresentationEvent {}
