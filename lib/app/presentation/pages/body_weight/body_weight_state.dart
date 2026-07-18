import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

class BodyWeightState extends Equatable {
  const BodyWeightState({required this.logs});

  // Most recent first, as the datasource returns them.
  final List<BodyWeightLog> logs;

  BodyWeightLog? get latest => logs.isEmpty ? null : logs.first;

  BodyWeightState copyWith({List<BodyWeightLog>? logs}) => BodyWeightState(logs: logs ?? this.logs);

  @override
  List<Object?> get props => [logs];
}
