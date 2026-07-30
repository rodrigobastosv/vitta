import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/domain/trends/entities/trends_verdict.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class TrendsState extends Equatable {
  const TrendsState({this.trendRange = .month, this.trends = const {}, this.isLoaded = true});

  final TrendRange trendRange;
  final Map<TrendArea, AreaTrend> trends;
  final bool isLoaded;

  ProgressStory get story => ProgressStory(days: trendRange.days, trends: trends);

  AreaTrend trendOf(TrendArea area) => story.trendOf(area);

  bool get hasData => story.hasData;

  Iterable<AreaTrend> get judgedTrends => story.judgedTrends;

  int get judgedAreaCount => story.judgedAreaCount;

  int get onTrackAreaCount => story.onTrackAreaCount;

  TrendsVerdict? get verdict => story.verdict;

  TrendsState copyWith({TrendRange? trendRange, Map<TrendArea, AreaTrend>? trends, bool? isLoaded}) =>
      TrendsState(trendRange: trendRange ?? this.trendRange, trends: trends ?? this.trends, isLoaded: isLoaded ?? this.isLoaded);

  @override
  List<Object?> get props => [trendRange, trends, isLoaded];
}
