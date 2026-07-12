import 'package:vitta/app/presentation/general/loading_presentation_event.dart';

enum WaterPresentationEvent implements LoadingPresentationEvent {
  showLoading(isLoading: true),
  hideLoading(isLoading: false);

  const WaterPresentationEvent({required this.isLoading});

  @override
  final bool isLoading;
}
