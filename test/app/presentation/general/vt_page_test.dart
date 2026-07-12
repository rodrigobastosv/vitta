import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';

sealed class _TestState {}

class _Idle implements _TestState {}

class _Loaded implements _TestState {}

sealed class _TestPresentationEvent {}

class _CustomEvent implements _TestPresentationEvent {
  const _CustomEvent();
}

class _TestCubit extends PresentationCubit<_TestState, _TestPresentationEvent> {
  _TestCubit({required this.gate}) : super(_Idle());

  final Completer<void> gate;

  @override
  void onInit() => load();

  Future<void> load() async {
    emitPresentation(const _CustomEvent());
    await gate.future;
    emit(_Loaded());
  }

  void fireCustomEvent() => emitPresentation(const _CustomEvent());
}

void main() {
  testWidgets('forwards a presentation event emitted from onInit() instead of dropping it', (tester) async {
    final gate = Completer<void>();
    await G.reset();
    G.registerFactory(() => _TestCubit(gate: gate));
    addTearDown(G.reset);

    _TestPresentationEvent? received;

    await tester.pumpWidget(
      MaterialApp(
        home: VTPage<_TestCubit, _TestState, _TestPresentationEvent>(
          onPresentation: (context, event) => received = event,
          builder: (context, cubit, state) => const Scaffold(body: SizedBox()),
        ),
      ),
    );
    await tester.pump();

    expect(received, isA<_CustomEvent>());

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('forwards presentation events fired after mount to an optional onPresentation callback', (tester) async {
    final gate = Completer<void>()..complete();
    await G.reset();
    G.registerFactory(() => _TestCubit(gate: gate));
    addTearDown(G.reset);

    _TestPresentationEvent? received;
    late _TestCubit cubit;

    await tester.pumpWidget(
      MaterialApp(
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
