import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vitta/app/design_system/components/general/vt_loading_overlay_indicator.dart';
import 'package:vitta/app/presentation/general/loading_presentation_event.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';

sealed class _TestState {}

class _Idle implements _TestState {}

class _Loaded implements _TestState {}

class _TestCubit extends PresentationCubit<_TestState> {
  _TestCubit() : super(_Idle());

  Future<void> load(Completer<void> gate) async {
    emitPresentation(LoadingPresentationEvent.show);
    await gate.future;
    emitPresentation(LoadingPresentationEvent.hide);
    emit(_Loaded());
  }
}

void main() {
  testWidgets('shows the loading overlay while a LoadingPresentationEvent.show is pending, hides it on .hide', (tester) async {
    final gate = Completer<void>();
    late _TestCubit cubit;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => LoaderOverlay(overlayWidgetBuilder: (_) => const VTLoadingOverlayIndicator(), child: child!),
        home: VTPage<_TestCubit, _TestState>(
          create: () => cubit = _TestCubit(),
          builder: (context, cubit, state) => const Scaffold(body: SizedBox()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(VTLoadingOverlayIndicator), findsNothing);

    unawaited(cubit.load(gate));
    await tester.pump();
    await tester.pump();

    expect(find.byType(VTLoadingOverlayIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byType(VTLoadingOverlayIndicator), findsNothing);
  });
}
