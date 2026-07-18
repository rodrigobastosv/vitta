import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class BodyWeightHistoryState extends Equatable {
  const BodyWeightHistoryState({this.logs = const [], this.trendRange = TrendRange.month});

  // Oldest first, ready to plot left-to-right.
  final List<BodyWeightLog> logs;
  final TrendRange trendRange;

  BodyWeightHistoryState copyWith({List<BodyWeightLog>? logs, TrendRange? trendRange}) =>
      BodyWeightHistoryState(logs: logs ?? this.logs, trendRange: trendRange ?? this.trendRange);

  @override
  List<Object?> get props => [logs, trendRange];
}
