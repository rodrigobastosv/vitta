sealed class DietPresentationEvent {}

class DietShowLoading implements DietPresentationEvent {}

class DietHideLoading implements DietPresentationEvent {}

class DietError implements DietPresentationEvent {
  const DietError({required this.message});

  final String message;
}
