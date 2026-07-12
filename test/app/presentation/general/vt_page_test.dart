import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/design_system/components/general/vt_loading_overlay_indicator.dart';
import 'package:vitta/app/presentation/general/loading_presentation_event.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';

sealed class _TestState {}

class _Idle implements _TestState {}

class _Loaded implements _TestState {}

enum _TestPresentationEvent implements LoadingPresentationEvent {
  showLoading(isLoading: true),
  hideLoading(isLoading: false);

  const _TestPresentationEvent({required this.isLoading});

  @override
  final bool isLoading;
}

class _TestCubit extends PresentationCubit<_TestState, _TestPresentationEvent> {
  _TestCubit({required this.gate}) : super(_Idle());

  final Completer<void> gate;

  @override
  void onInit() => load();

  Future<void> load() async {
    emitPresentation(_TestPresentationEvent.showLoading);
    await gate.future;
    emitPresentation(_TestPresentationEvent.hideLoading);
    emit(_Loaded());
  }
}

void main() {
  testWidgets('calls onInit on mount and shows the overlay for its pending show/hide, not losing the first event', (
    tester,
  ) async {
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
}
