import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/domain/workout/use_cases/get_rest_duration_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/save_rest_duration_use_case.dart';

class RestTimerCubit extends Cubit<RestTimerState> with WidgetsBindingObserver {
  RestTimerCubit({required this._getRestDurationUseCase, required this._saveRestDurationUseCase}) : super(const RestTimerState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration _tick = Duration(seconds: 1);
  static const Duration _countdownFrom = Duration(seconds: 3);

  final GetRestDurationUseCase _getRestDurationUseCase;
  final SaveRestDurationUseCase _saveRestDurationUseCase;

  Timer? _timer;
  DateTime? _deadline;

  Duration get configuredRest => _getRestDurationUseCase();

  Future<void> changeRest(Duration rest) async {
    await _saveRestDurationUseCase(rest);
    emit(state.copyWith(configured: rest));
  }

  void start({Duration? rest, String? label}) {
    final duration = rest ?? _getRestDurationUseCase();
    _timer?.cancel();
    _deadline = clock.now().add(duration);
    emit(RestTimerState(remaining: duration, total: duration, label: label, configured: _getRestDurationUseCase()));
    _timer = Timer.periodic(_tick, (_) => _syncToDeadline());
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

  void skip() {
    _timer?.cancel();
    _deadline = null;
    emit(RestTimerState(configured: _getRestDurationUseCase()));
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
    if (remaining <= _countdownFrom) {
      VTHaptics.selection();
    }
    emit(state.copyWith(remaining: remaining));
  }

  Duration _remainingUntil(DateTime deadline) {
    final untilDeadline = deadline.difference(clock.now());
    return untilDeadline.isNegative ? Duration.zero : _tick * (untilDeadline.inMilliseconds / _tick.inMilliseconds).ceil();
  }

  void _finish() {
    VTHaptics.success();
    skip();
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    return super.close();
  }
}
