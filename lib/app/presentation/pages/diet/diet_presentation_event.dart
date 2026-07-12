import 'package:vitta/app/presentation/general/vt_presentation_event.dart';

sealed class DietPresentationEvent {}

class DietShowLoading extends VTShowLoading implements DietPresentationEvent {}

class DietHideLoading extends VTHideLoading implements DietPresentationEvent {}
