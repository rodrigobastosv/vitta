import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

sealed class SleepState extends Equatable {
  const SleepState();

  @override
  List<Object?> get props => [];
}

class SleepLoaded extends SleepState {
  const SleepLoaded({required this.logs});

  final List<SleepLog> logs;

  @override
  List<Object?> get props => [logs];
}

class SleepError extends SleepState {
  const SleepError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
