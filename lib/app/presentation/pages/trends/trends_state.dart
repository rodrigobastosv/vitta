import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/domain/trends/entities/trends_verdict.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class TrendsState extends Equatable {
  const TrendsState({this.trendRange = .month, this.trends = const {}, this.isLoaded = true});

  final TrendRange trendRange;
  final Map<TrendArea, AreaTrend> trends;
  final bool isLoaded;

  AreaTrend trendOf(TrendArea area) => trends[area] ?? const AreaTrend();

  bool get hasData => trends.values.any((trend) => trend.hasData);

  Iterable<AreaTrend> get judgedTrends => trends.values.where((trend) => trend.isJudged);

  int get judgedAreaCount => judgedTrends.length;

  int get onTrackAreaCount => judgedTrends.where((trend) => trend.isOnTrack).length;

  TrendsVerdict? get verdict => judgedAreaCount == 0 ? null : TrendsVerdict.forOnTrackRatio(onTrackAreaCount / judgedAreaCount);

  TrendsState copyWith({TrendRange? trendRange, Map<TrendArea, AreaTrend>? trends, bool? isLoaded}) =>
      TrendsState(trendRange: trendRange ?? this.trendRange, trends: trends ?? this.trends, isLoaded: isLoaded ?? this.isLoaded);

  @override
  List<Object?> get props => [trendRange, trends, isLoaded];
}
