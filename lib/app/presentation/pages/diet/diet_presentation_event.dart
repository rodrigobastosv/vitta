sealed class DietPresentationEvent {}

class DietShowLoading implements DietPresentationEvent {}

class DietHideLoading implements DietPresentationEvent {}

class DietError implements DietPresentationEvent {
  const DietError({required this.message, required this.date});

  final String message;
  final DateTime date;
}
