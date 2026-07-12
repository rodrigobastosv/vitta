import 'package:vitta/app/presentation/general/vt_presentation_event.dart';

sealed class SleepPresentationEvent {}

class SleepShowLoading extends VTShowLoading implements SleepPresentationEvent {
  const SleepShowLoading();
}

class SleepHideLoading extends VTHideLoading implements SleepPresentationEvent {
  const SleepHideLoading();
}
