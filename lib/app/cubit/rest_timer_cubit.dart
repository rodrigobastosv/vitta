import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/services/sound/sound_cue.dart';
import 'package:vitta/app/core/services/sound/sound_service.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/domain/workout/use_cases/get_rest_duration_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_rest_sound_enabled_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/save_rest_duration_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/save_rest_sound_enabled_use_case.dart';

class RestTimerCubit extends Cubit<RestTimerState> with WidgetsBindingObserver {
  RestTimerCubit({
    required GetRestDurationUseCase getRestDurationUseCase,
    required GetRestSoundEnabledUseCase getRestSoundEnabledUseCase,
    required this._saveRestDurationUseCase,
    required this._saveRestSoundEnabledUseCase,
    required this._soundService,
  }) : _getRestDurationUseCase = getRestDurationUseCase,
       _getRestSoundEnabledUseCase = getRestSoundEnabledUseCase,
       super(RestTimerState(configured: getRestDurationUseCase(), isSoundEnabled: getRestSoundEnabledUseCase())) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration _tick = Duration(seconds: 1);
  static const Duration _alertFrom = Duration(seconds: 3);

  final GetRestDurationUseCase _getRestDurationUseCase;
  final SaveRestDurationUseCase _saveRestDurationUseCase;
  final GetRestSoundEnabledUseCase _getRestSoundEnabledUseCase;
  final SaveRestSoundEnabledUseCase _saveRestSoundEnabledUseCase;
  final SoundService _soundService;

  Timer? _timer;
  DateTime? _deadline;

  Duration get configuredRest => _getRestDurationUseCase();

  bool get isSoundEnabled => _getRestSoundEnabledUseCase();

  // An explicit change of the rest length is the only thing that moves the saved
  // default - extend/shorten move this rest's deadline and nothing else. It also
  // retargets a rest already running, so the control never reads as inert.
  Future<void> changeRest(Duration rest) async {
    await _saveRestDurationUseCase(rest);
    emit(state.copyWith(configured: rest));
    if (_deadline != null) {
      _restart(rest);
    }
  }

  Future<void> changeSoundEnabled({required bool isEnabled}) async {
    await _saveRestSoundEnabledUseCase(isEnabled: isEnabled);
    emit(state.copyWith(isSoundEnabled: isEnabled));
  }

  void start({required String exerciseId, Duration? rest, String? label}) {
    final duration = rest ?? _getRestDurationUseCase();
    _deadline = clock.now().add(duration);
    emit(
      RestTimerState(
        remaining: duration,
        total: duration,
        label: label,
        exerciseId: exerciseId,
        configured: _getRestDurationUseCase(),
        isSoundEnabled: state.isSoundEnabled,
      ),
    );
    _schedule();
  }

  void extend() => _shift(RestTimerState.adjustStep);

  void shorten() => _shift(-RestTimerState.adjustStep);

  void _shift(Duration by) {
    final deadline = _deadline;
    if (deadline == null) {
      return;
    }
    final remaining = _remainingUntil(deadline) + by;
    if (remaining <= Duration.zero) {
      skip();
      return;
    }
    _deadline = deadline.add(by);
    emit(state.copyWith(remaining: remaining, total: state.total + by));
  }

  void _restart(Duration rest) {
    _deadline = clock.now().add(rest);
    emit(state.copyWith(remaining: rest, total: rest));
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _syncToDeadline());
  }

  void skip() {
    _timer?.cancel();
    _deadline = null;
    emit(RestTimerState(configured: _getRestDurationUseCase(), isSoundEnabled: state.isSoundEnabled));
  }

  // A rest times the gap before the next set of one exercise, so finishing that
  // exercise ends it - and only it, since a rest belonging to another exercise
  // is still counting down towards a set that is coming (issues #228 and #277).
  void endFor(String exerciseId) {
    if (state.belongsTo(exerciseId)) {
      skip();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .resumed) {
      _syncToDeadline();
    }
  }

  void _syncToDeadline() {
    final deadline = _deadline;
    if (deadline == null) {
      return;
    }
    final remaining = _remainingUntil(deadline);
    if (remaining <= Duration.zero) {
      _finish();
      return;
    }
    if (remaining <= _alertFrom) {
      VTHaptics.countdown();
      _playCue(SoundCue.restTick);
    }
    emit(state.copyWith(remaining: remaining));
  }

  Duration _remainingUntil(DateTime deadline) {
    final untilDeadline = deadline.difference(clock.now());
    return untilDeadline.isNegative ? Duration.zero : _tick * (untilDeadline.inMilliseconds / _tick.inMilliseconds).ceil();
  }

  void _finish() {
    VTHaptics.alarm();
    _playCue(SoundCue.restEnd);
    skip();
  }

  void _playCue(SoundCue cue) {
    if (state.isSoundEnabled) {
      _soundService.play(cue);
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    return super.close();
  }
}
