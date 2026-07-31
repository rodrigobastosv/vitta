import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/sound/sound_cue.dart';
import 'package:vitta/app/core/services/sound/sound_service.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';

import '../../mocks/services_mocks.dart';
import '../../mocks/use_cases_mocks.dart';

RestTimerCubit buildCubit({
  Duration configured = const Duration(seconds: 90),
  bool isSoundEnabled = true,
  MockSaveRestDurationUseCase? saveRestDurationUseCase,
  SoundService? soundService,
}) {
  final getRestDurationUseCase = MockGetRestDurationUseCase();
  when(getRestDurationUseCase.call).thenReturn(configured);
  final saveRestDuration = saveRestDurationUseCase ?? MockSaveRestDurationUseCase();
  when(() => saveRestDuration(any())).thenAnswer((_) async {});
  final getRestSoundEnabledUseCase = MockGetRestSoundEnabledUseCase();
  when(getRestSoundEnabledUseCase.call).thenReturn(isSoundEnabled);
  final saveRestSoundEnabledUseCase = MockSaveRestSoundEnabledUseCase();
  when(() => saveRestSoundEnabledUseCase(isEnabled: any(named: 'isEnabled'))).thenAnswer((_) async {});
  return RestTimerCubit(
    getRestDurationUseCase: getRestDurationUseCase,
    saveRestDurationUseCase: saveRestDuration,
    getRestSoundEnabledUseCase: getRestSoundEnabledUseCase,
    saveRestSoundEnabledUseCase: saveRestSoundEnabledUseCase,
    soundService: soundService ?? MockSoundService(),
  );
}

void announceLifecycleState(AppLifecycleState lifecycleState) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.lifecycle.name,
    const StringCodec().encodeMessage(lifecycleState.toString()),
    (_) {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(SoundCue.restTick);
  });

  test('starts idle, so nothing is shown before the first set', () {
    final cubit = buildCubit();

    expect(cubit.state.isRunning, isFalse);

    cubit.close();
  });

  test('counts down and clears itself when it reaches zero', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 3));

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
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      async.elapse(const Duration(seconds: 10));
      cubit.extend();

      expect(cubit.state.remaining, const Duration(seconds: 80));
      expect(cubit.state.total, const Duration(seconds: 90), reason: 'the bar would jump backwards if only remaining grew');

      cubit.close();
    });
  });

  test('starting again while running replaces the previous rest rather than stacking', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      async.elapse(const Duration(seconds: 5));
      cubit.start(exerciseId: 'bench', rest: const Duration(seconds: 30));
      async.elapse(const Duration(seconds: 1));

      expect(cubit.state.remaining, const Duration(seconds: 29));

      cubit.close();
    });
  });

  test('a rest with no explicit length uses the saved preference', () {
    fakeAsync((async) {
      final cubit = buildCubit(configured: const Duration(seconds: 45))..start(exerciseId: 'bench');

      expect(cubit.state.remaining, const Duration(seconds: 45));

      cubit.close();
    });
  });

  test('shortening past zero ends the rest rather than going negative', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 20));

      cubit.shorten();

      expect(cubit.state.isRunning, isFalse);

      cubit.close();
    });
  });

  test('skipping clears it immediately', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      cubit.skip();
      async.elapse(const Duration(seconds: 5));

      expect(cubit.state.isRunning, isFalse);

      cubit.close();
    });
  });

  test('time that passes with no tick still comes off the countdown', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      async.elapseBlocking(const Duration(seconds: 20));
      async.elapse(const Duration(seconds: 1));

      expect(cubit.state.remaining, const Duration(seconds: 39), reason: 'the deadline is what counts down, not how many ticks were serviced');

      cubit.close();
    });
  });

  test('a rest whose deadline passed while the app was away is finished on resume', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      async
        ..elapseBlocking(const Duration(minutes: 5))
        ..flushMicrotasks();
      announceLifecycleState(.paused);
      announceLifecycleState(.resumed);
      async.flushMicrotasks();

      expect(cubit.state.isRunning, isFalse, reason: 'coming back to a countdown that should have ended long ago must not leave it stuck');

      cubit.close();
    });
  });

  test('a rest still running when the app comes back shows the time that actually remains', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 90));

      async.elapseBlocking(const Duration(seconds: 30));
      announceLifecycleState(.paused);
      announceLifecycleState(.resumed);
      async.flushMicrotasks();

      expect(cubit.state.remaining, const Duration(seconds: 60));

      cubit.close();
    });
  });

  test('extending after unserviced time grows the rest from what is actually left', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      async.elapseBlocking(const Duration(seconds: 20));
      cubit.extend();

      expect(cubit.state.remaining, const Duration(seconds: 70));
      expect(cubit.state.total, const Duration(seconds: 90));

      cubit.close();
    });
  });

  test('opens on the saved rest length rather than the shipped default', () {
    final cubit = buildCubit(configured: const Duration(minutes: 2));

    expect(cubit.state.configured, const Duration(minutes: 2), reason: 'the stored preference is what a fresh launch reads');

    cubit.close();
  });

  test('an ad-hoc extension never becomes the new default', () {
    fakeAsync((async) {
      final saveRestDurationUseCase = MockSaveRestDurationUseCase();
      final cubit = buildCubit(saveRestDurationUseCase: saveRestDurationUseCase)..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      cubit
        ..extend()
        ..shorten();

      verifyNever(() => saveRestDurationUseCase(any()));

      cubit.close();
    });
  });

  test('changing the rest length saves it and retargets the rest already running', () {
    fakeAsync((async) {
      final saveRestDurationUseCase = MockSaveRestDurationUseCase();
      final cubit = buildCubit(saveRestDurationUseCase: saveRestDurationUseCase)..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      async.elapse(const Duration(seconds: 10));
      cubit.changeRest(const Duration(seconds: 120));
      async.flushMicrotasks();

      verify(() => saveRestDurationUseCase(const Duration(seconds: 120))).called(1);
      expect(cubit.state.configured, const Duration(seconds: 120));
      expect(cubit.state.remaining, const Duration(seconds: 120), reason: 'a control that changes nothing on screen reads as one that did not save');

      cubit.close();
    });
  });

  test('finishing another exercise leaves a rest that belongs to this one running', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      cubit.endFor('squat');

      expect(cubit.state.isRunning, isTrue);

      cubit
        ..endFor('bench')
        ..close();
    });
  });

  test('finishing the exercise the rest belongs to ends it', () {
    fakeAsync((async) {
      final cubit = buildCubit()..start(exerciseId: 'bench', rest: const Duration(seconds: 60));

      cubit.endFor('bench');

      expect(cubit.state.isRunning, isFalse);

      cubit.close();
    });
  });

  test('the last seconds and the end are audible, so a rest can be heard rather than watched', () {
    fakeAsync((async) {
      final soundService = MockSoundService();
      final cubit = buildCubit(soundService: soundService)..start(exerciseId: 'bench', rest: const Duration(seconds: 3));

      async.elapse(const Duration(seconds: 2));
      verify(() => soundService.play(SoundCue.restTick)).called(2);

      async.elapse(const Duration(seconds: 1));
      verify(() => soundService.play(SoundCue.restEnd)).called(1);

      cubit.close();
    });
  });

  test('turning the sound off leaves the rest silent', () {
    fakeAsync((async) {
      final soundService = MockSoundService();
      final cubit = buildCubit(isSoundEnabled: false, soundService: soundService)..start(exerciseId: 'bench', rest: const Duration(seconds: 3));

      async.elapse(const Duration(seconds: 3));

      verifyNever(() => soundService.play(any()));

      cubit.close();
    });
  });
}
