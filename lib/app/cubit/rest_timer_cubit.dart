import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';

class RestTimerCubit extends Cubit<RestTimerState> {
  RestTimerCubit() : super(const RestTimerState());

  static const Duration _tick = Duration(seconds: 1);

  Timer? _timer;

  void start([Duration rest = RestTimerState.defaultRest]) {
    _timer?.cancel();
    emit(RestTimerState(remaining: rest, total: rest));
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void extend() {
    if (!state.isRunning) {
      return;
    }
    emit(state.copyWith(remaining: state.remaining + RestTimerState.extendStep, total: state.total + RestTimerState.extendStep));
  }

  void skip() {
    _timer?.cancel();
    emit(const RestTimerState());
  }

  void _onTick() {
    final remaining = state.remaining - _tick;
    if (remaining > Duration.zero) {
      emit(state.copyWith(remaining: remaining));
      return;
    }
    _timer?.cancel();
    VTHaptics.success();
    emit(const RestTimerState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
