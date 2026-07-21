import 'package:equatable/equatable.dart';

class RestTimerState extends Equatable {
  const RestTimerState({this.remaining = Duration.zero, this.total = Duration.zero, this.label, this.configured = defaultRest});

  static const Duration defaultRest = Duration(seconds: 90);
  static const Duration adjustStep = Duration(seconds: 30);
  static const Duration minRest = Duration(seconds: 15);
  static const Duration maxRest = Duration(minutes: 5);

  final Duration remaining;
  final Duration total;
  final String? label;
  final Duration configured;

  bool get isRunning => remaining > Duration.zero;

  double get progress => total == Duration.zero ? 0 : remaining.inMilliseconds / total.inMilliseconds;

  RestTimerState copyWith({Duration? remaining, Duration? total, String? label, Duration? configured}) =>
      RestTimerState(remaining: remaining ?? this.remaining, total: total ?? this.total, label: label ?? this.label, configured: configured ?? this.configured);

  @override
  List<Object?> get props => [remaining, total, label, configured];
}
