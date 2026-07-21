import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

class BodyWeightState extends Equatable {
  const BodyWeightState({required this.logs, this.isLoaded = true});

  // Most recent first, as the datasource returns them.
  final List<BodyWeightLog> logs;
  final bool isLoaded;

  BodyWeightLog? get latest => logs.isEmpty ? null : logs.first;

  BodyWeightState copyWith({List<BodyWeightLog>? logs, bool? isLoaded}) => BodyWeightState(isLoaded: isLoaded ?? this.isLoaded, logs: logs ?? this.logs);

  @override
  List<Object?> get props => [isLoaded, logs];
}
