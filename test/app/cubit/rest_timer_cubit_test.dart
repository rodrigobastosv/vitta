import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts idle, so nothing is shown before the first set', () {
    final cubit = RestTimerCubit();

    expect(cubit.state.isRunning, isFalse);

    cubit.close();
  });

  test('counts down and clears itself when it reaches zero', () {
    fakeAsync((async) {
      final cubit = RestTimerCubit()..start(const Duration(seconds: 3));

      expect(cubit.state.remaining, const Duration(seconds: 3));

      async.elapse(const Duration(seconds: 2));
      expect(cubit.state.remaining, const Duration(seconds: 1));

      async.elapse(const Duration(seconds: 1));
      expect(cubit.state.isRunning, isFalse, reason: 'a finished rest stops showing itself');

      cubit.close();
    });
  });

  test('extending adds to both the remaining time and the bar it fills', () {
    fakeAsync((async) {
      final cubit = RestTimerCubit()..start(const Duration(seconds: 60));

      async.elapse(const Duration(seconds: 10));
      cubit.extend();

      expect(cubit.state.remaining, const Duration(seconds: 80));
      expect(cubit.state.total, const Duration(seconds: 90), reason: 'the bar would jump backwards if only remaining grew');

      cubit.close();
    });
  });

  test('starting again while running replaces the previous rest rather than stacking', () {
    fakeAsync((async) {
      final cubit = RestTimerCubit()..start(const Duration(seconds: 60));

      async.elapse(const Duration(seconds: 5));
      cubit.start(const Duration(seconds: 30));
      async.elapse(const Duration(seconds: 1));

      expect(cubit.state.remaining, const Duration(seconds: 29));

      cubit.close();
    });
  });

  test('skipping clears it immediately', () {
    fakeAsync((async) {
      final cubit = RestTimerCubit()..start(const Duration(seconds: 60));

      cubit.skip();
      async.elapse(const Duration(seconds: 5));

      expect(cubit.state.isRunning, isFalse);

      cubit.close();
    });
  });
}
