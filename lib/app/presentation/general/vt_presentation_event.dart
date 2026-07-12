abstract interface class LoadingPresentationEvent {
  bool get isLoading;
}

abstract class VTPresentationEvent {
  const VTPresentationEvent();
}

class VTShowLoading extends VTPresentationEvent implements LoadingPresentationEvent {
  const VTShowLoading();

  @override
  bool get isLoading => true;
}

class VTHideLoading extends VTPresentationEvent implements LoadingPresentationEvent {
  const VTHideLoading();

  @override
  bool get isLoading => false;
}
