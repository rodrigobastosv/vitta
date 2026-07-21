import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class SleepState extends Equatable {
  const SleepState({required this.logs, this.isLoaded = true});

  final List<SleepLog> logs;
  final bool isLoaded;

  SleepState copyWith({List<SleepLog>? logs, bool? isLoaded}) => SleepState(isLoaded: isLoaded ?? this.isLoaded, logs: logs ?? this.logs);

  @override
  List<Object?> get props => [isLoaded, logs];
}
