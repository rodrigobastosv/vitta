import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PresentationCubit<S, P> extends Cubit<S> with BlocPresentationMixin<S, P> {
  PresentationCubit(super.initialState);

  void onInit() {}

  /// Runs [load] bracketed by the loading overlay, but only when [showOverlay] is
  /// true. Skeleton-backed reads pass `showOverlay: state.isLoaded`: the first
  /// read (isLoaded == false) shows the skeleton instead of the overlay, while a
  /// reload over already-known data (retry, paging, a post-write refresh) still
  /// gets it. Centralised here so the initial-load-vs-reload policy lives in one
  /// place rather than being copy-pasted into every load method. See CLAUDE.md >
  /// Skeletons.
  Future<T> withLoadingOverlay<T>(
    Future<T> Function() load, {
    required bool showOverlay,
    required P showLoadingEvent,
    required P hideLoadingEvent,
  }) async {
    if (showOverlay) {
      emitPresentation(showLoadingEvent);
    }
    try {
      return await load();
    } finally {
      if (showOverlay) {
        emitPresentation(hideLoadingEvent);
      }
    }
  }
}
