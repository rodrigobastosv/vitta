import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PresentationCubit<S, P> extends Cubit<S> with BlocPresentationMixin<S, P> {
  PresentationCubit(super.initialState);

  void onInit() {}

  /// Guards every state emit against a closed cubit. A page-scoped cubit is
  /// closed when its page pops, but an in-flight async load (a Supabase call, a
  /// debounce) can resolve afterwards and try to `emit(...)` — which `bloc`
  /// turns into an uncaught `StateError` that Sentry then reports as a crash.
  /// Dropping the emit is correct: a closed cubit's state is never read again.
  @override
  void emit(S state) {
    if (isClosed) {
      return;
    }
    super.emit(state);
  }

  /// The presentation-event twin of the [emit] guard above. `emitPresentation`
  /// adds to a broadcast `StreamController` that `close()` has already closed,
  /// so a late one throws `Bad state: Cannot add event after closing` — the same
  /// crash from the same async-gap cause. See CLAUDE.md > State management.
  @override
  void emitPresentation(P event) {
    if (isClosed) {
      return;
    }
    super.emitPresentation(event);
  }

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
