import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class SleepState extends Equatable {
  const SleepState({required this.logs});

  final List<SleepLog> logs;

  SleepState copyWith({List<SleepLog>? logs}) => SleepState(logs: logs ?? this.logs);

  @override
  List<Object?> get props => [logs];
}
