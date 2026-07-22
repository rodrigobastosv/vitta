import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';

sealed class _TestPresentationEvent {}

class _Ping implements _TestPresentationEvent {
  const _Ping();
}

class _TestCubit extends PresentationCubit<int, _TestPresentationEvent> {
  _TestCubit() : super(0);

  void bump() => emit(state + 1);

  void ping() => emitPresentation(const _Ping());
}

void main() {
  test('emits normally while open', () {
    final cubit = _TestCubit();
    addTearDown(cubit.close);

    cubit.bump();

    expect(cubit.state, 1);
  });

  test('emit after close is dropped instead of throwing', () async {
    final cubit = _TestCubit();
    await cubit.close();

    expect(cubit.bump, returnsNormally);
    expect(cubit.state, 0);
  });

  test('emitPresentation after close is dropped instead of throwing', () async {
    final cubit = _TestCubit();
    final events = <_TestPresentationEvent>[];
    cubit.presentation.listen(events.add);
    await cubit.close();

    expect(cubit.ping, returnsNormally);
    expect(events, isEmpty);
  });
}
