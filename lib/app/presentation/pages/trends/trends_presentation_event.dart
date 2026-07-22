sealed class TrendsPresentationEvent {}

class TrendsShowLoading implements TrendsPresentationEvent {}

class TrendsHideLoading implements TrendsPresentationEvent {}

class TrendsError implements TrendsPresentationEvent {
  const TrendsError({required this.message});

  final String message;
}
