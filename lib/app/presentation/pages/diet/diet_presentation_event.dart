import 'package:vitta/app/presentation/general/loading_presentation_event.dart';

enum DietPresentationEvent implements LoadingPresentationEvent {
  showLoading(isLoading: true),
  hideLoading(isLoading: false);

  const DietPresentationEvent({required this.isLoading});

  @override
  final bool isLoading;
}
