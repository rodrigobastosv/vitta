import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/domain/workout/use_cases/get_rest_duration_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/save_rest_duration_use_case.dart';

class RestTimerCubit extends Cubit<RestTimerState> {
  RestTimerCubit({required this._getRestDurationUseCase, required this._saveRestDurationUseCase}) : super(const RestTimerState());

  static const Duration _tick = Duration(seconds: 1);
  static const Duration _countdownFrom = Duration(seconds: 3);

  final GetRestDurationUseCase _getRestDurationUseCase;
  final SaveRestDurationUseCase _saveRestDurationUseCase;

  Timer? _timer;

  Duration get configuredRest => _getRestDurationUseCase();

  Future<void> changeRest(Duration rest) async {
    await _saveRestDurationUseCase(rest);
    emit(state.copyWith(configured: rest));
  }

  void start({Duration? rest, String? label}) {
    final duration = rest ?? _getRestDurationUseCase();
    _timer?.cancel();
    emit(RestTimerState(remaining: duration, total: duration, label: label, configured: _getRestDurationUseCase()));
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void extend() => _shift(RestTimerState.adjustStep);

  void shorten() => _shift(-RestTimerState.adjustStep);

  void _shift(Duration by) {
    if (!state.isRunning) {
      return;
    }
    final remaining = state.remaining + by;
    if (remaining <= Duration.zero) {
      skip();
      return;
    }
    emit(state.copyWith(remaining: remaining, total: state.total + by));
  }

  void skip() {
    _timer?.cancel();
    emit(RestTimerState(configured: _getRestDurationUseCase()));
  }

  void _onTick() {
    final remaining = state.remaining - _tick;
    if (remaining > Duration.zero) {
      if (remaining <= _countdownFrom) {
        VTHaptics.selection();
      }
      emit(state.copyWith(remaining: remaining));
      return;
    }
    _timer?.cancel();
    VTHaptics.success();
    emit(RestTimerState(configured: _getRestDurationUseCase()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
