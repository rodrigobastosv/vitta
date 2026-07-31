import 'package:equatable/equatable.dart';

class RestTimerState extends Equatable {
  const RestTimerState({
    this.remaining = Duration.zero,
    this.total = Duration.zero,
    this.label,
    this.exerciseId,
    this.configured = defaultRest,
    this.isSoundEnabled = true,
  });

  static const Duration defaultRest = Duration(seconds: 90);
  static const Duration adjustStep = Duration(seconds: 30);
  static const Duration minRest = Duration(seconds: 15);
  static const Duration maxRest = Duration(minutes: 5);

  final Duration remaining;
  final Duration total;
  final String? label;

  // Which workout exercise the rest belongs to. The timer is a root singleton
  // outliving every page, so without an identity a rest left over from one
  // exercise reads as the next exercise's own countdown (issue #277).
  final String? exerciseId;
  final Duration configured;
  final bool isSoundEnabled;

  bool get isRunning => remaining > Duration.zero;

  double get progress => total == Duration.zero ? 0 : remaining.inMilliseconds / total.inMilliseconds;

  bool belongsTo(String exerciseId) => this.exerciseId == exerciseId;

  RestTimerState copyWith({Duration? remaining, Duration? total, String? label, String? exerciseId, Duration? configured, bool? isSoundEnabled}) =>
      RestTimerState(
        remaining: remaining ?? this.remaining,
        total: total ?? this.total,
        label: label ?? this.label,
        exerciseId: exerciseId ?? this.exerciseId,
        configured: configured ?? this.configured,
        isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      );

  @override
  List<Object?> get props => [remaining, total, label, exerciseId, configured, isSoundEnabled];
}
