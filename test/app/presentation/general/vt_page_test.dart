import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/design_system/components/general/vt_loading_overlay_indicator.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/general/vt_presentation_event.dart';

sealed class _TestState {}

class _Idle implements _TestState {}

class _Loaded implements _TestState {}

sealed class _TestPresentationEvent {}

class _ShowLoading extends VTShowLoading implements _TestPresentationEvent {
  const _ShowLoading();
}

class _HideLoading extends VTHideLoading implements _TestPresentationEvent {
  const _HideLoading();
}

class _CustomEvent implements _TestPresentationEvent {
  const _CustomEvent();
}

class _TestCubit extends PresentationCubit<_TestState, _TestPresentationEvent> {
  _TestCubit({required this.gate}) : super(_Idle());

  final Completer<void> gate;

  @override
  void onInit() => load();

  Future<void> load() async {
    emitPresentation(const _ShowLoading());
    await gate.future;
    emitPresentation(const _HideLoading());
    emit(_Loaded());
  }

  void fireCustomEvent() => emitPresentation(const _CustomEvent());
}

void main() {
  testWidgets("shows/hides the overlay for onInit()'s loading events even with no onPresentation callback", (tester) async {
    final gate = Completer<void>();
    await G.reset();
    G.registerFactory(() => _TestCubit(gate: gate));
    addTearDown(G.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => LoaderOverlay(overlayWidgetBuilder: (_) => const VTLoadingOverlayIndicator(), child: child!),
        home: VTPage<_TestCubit, _TestState, _TestPresentationEvent>(
          builder: (context, cubit, state) => const Scaffold(body: SizedBox()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(VTLoadingOverlayIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byType(VTLoadingOverlayIndicator), findsNothing);
  });

  testWidgets('also forwards non-loading presentation events to an optional onPresentation callback', (tester) async {
    final gate = Completer<void>()..complete();
    await G.reset();
    G.registerFactory(() => _TestCubit(gate: gate));
    addTearDown(G.reset);

    _TestPresentationEvent? received;
    late _TestCubit cubit;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => LoaderOverlay(overlayWidgetBuilder: (_) => const VTLoadingOverlayIndicator(), child: child!),
        home: VTPage<_TestCubit, _TestState, _TestPresentationEvent>(
          onPresentation: (context, event) => received = event,
          builder: (context, thisCubit, state) {
            cubit = thisCubit;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    cubit.fireCustomEvent();
    await tester.pump();

    expect(received, isA<_CustomEvent>());
  });
}
