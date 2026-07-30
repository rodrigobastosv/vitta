import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/domain/trends/entities/trends_verdict.dart';

void main() {
  AreaTrend buildTrend({required double average, double? goal}) => AreaTrend(
    days: [DateTime(2026, 7, 20)],
    valuesByDate: {DateTime(2026, 7, 20): average},
    goal: goal,
  );

  test('counts only the areas that have a goal to be judged against', () {
    final story = ProgressStory(
      days: 30,
      trends: {
        .nutrition: buildTrend(average: 2000, goal: 2000),
        .water: buildTrend(average: 500, goal: 2000),
        .workout: buildTrend(average: 4000),
      },
    );

    expect(story.judgedAreaCount, 2);
    expect(story.onTrackAreaCount, 1);
    expect(story.verdict, TrendsVerdict.mixed);
  });

  test('has no verdict when no goal area has data, rather than scoring zero', () {
    final story = ProgressStory(days: 7, trends: {.workout: buildTrend(average: 4000)});

    expect(story.judgedAreaCount, 0);
    expect(story.verdict, isNull);
    expect(story.hasData, isTrue);
  });

  test('lists the areas that have data in area order', () {
    final story = ProgressStory(
      days: 7,
      trends: {
        .bodyWeight: buildTrend(average: 74),
        .nutrition: buildTrend(average: 2000, goal: 2000),
        .sleep: const AreaTrend(),
      },
    );

    expect(story.areasWithData, [TrendArea.nutrition, TrendArea.bodyWeight]);
  });

  test('an area with no trend at all reads as an empty one', () {
    const story = ProgressStory(days: 7);

    expect(story.trendOf(.sleep).hasData, isFalse);
    expect(story.hasData, isFalse);
  });
}
