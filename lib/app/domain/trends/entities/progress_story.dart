import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/domain/trends/entities/trends_verdict.dart';

// What a period of tracking amounts to, in the terms the trends page already
// answers in: the window it covers and one AreaTrend per area. It is the whole
// payload of a shareable card, which is why the verdict arithmetic lives here
// rather than on TrendsState - the same figures are read by a page the user
// exports as an image, and a second copy of "how many goals are holding" could
// disagree with the one on screen.
class ProgressStory extends Equatable {
  const ProgressStory({required this.days, this.trends = const {}});

  final int days;
  final Map<TrendArea, AreaTrend> trends;

  AreaTrend trendOf(TrendArea area) => trends[area] ?? const AreaTrend();

  bool get hasData => trends.values.any((trend) => trend.hasData);

  List<TrendArea> get areasWithData => [
    for (final area in TrendArea.values)
      if (trendOf(area).hasData) area,
  ];

  Iterable<AreaTrend> get judgedTrends => trends.values.where((trend) => trend.isJudged);

  int get judgedAreaCount => judgedTrends.length;

  int get onTrackAreaCount => judgedTrends.where((trend) => trend.isOnTrack).length;

  TrendsVerdict? get verdict => judgedAreaCount == 0 ? null : TrendsVerdict.forOnTrackRatio(onTrackAreaCount / judgedAreaCount);

  @override
  List<Object?> get props => [days, trends];
}
