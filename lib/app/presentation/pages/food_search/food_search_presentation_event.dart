import 'package:vitta/app/presentation/general/loading_presentation_event.dart';

enum FoodSearchPresentationEvent implements LoadingPresentationEvent {
  showLoading(isLoading: true),
  hideLoading(isLoading: false);

  const FoodSearchPresentationEvent({required this.isLoading});

  @override
  final bool isLoading;
}
