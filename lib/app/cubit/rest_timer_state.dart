import 'package:equatable/equatable.dart';

class RestTimerState extends Equatable {
  const RestTimerState({this.remaining = Duration.zero, this.total = Duration.zero});

  static const Duration defaultRest = Duration(seconds: 90);
  static const Duration extendStep = Duration(seconds: 30);

  final Duration remaining;
  final Duration total;

  bool get isRunning => remaining > Duration.zero;

  double get progress => total == Duration.zero ? 0 : remaining.inMilliseconds / total.inMilliseconds;

  RestTimerState copyWith({Duration? remaining, Duration? total}) => RestTimerState(remaining: remaining ?? this.remaining, total: total ?? this.total);

  @override
  List<Object?> get props => [remaining, total];
}
