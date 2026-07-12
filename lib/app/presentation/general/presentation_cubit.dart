import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PresentationCubit<S, P> extends Cubit<S> with BlocPresentationMixin<S, P> {
  PresentationCubit(super.initialState);

  void onInit() {}
}
