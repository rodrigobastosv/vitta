sealed class HomePresentationEvent {}

class HomeShowLoading implements HomePresentationEvent {}

class HomeHideLoading implements HomePresentationEvent {}

class HomeError implements HomePresentationEvent {
  const HomeError({required this.message});

  final String message;
}
