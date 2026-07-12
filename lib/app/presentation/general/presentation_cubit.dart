import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/presentation/general/loading_presentation_event.dart';

abstract class PresentationCubit<S> extends Cubit<S> with BlocPresentationMixin<S, LoadingPresentationEvent> {
  PresentationCubit(super.initialState);
}
