import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/trend_direction.dart';
import 'package:vitta/app/domain/trends/entities/trends_verdict.dart';

void main() {
  AreaTrend buildTrend({Map<DateTime, double> current = const {}, Map<DateTime, double> previous = const {}, double? goal}) => AreaTrend(
    days: [DateTime(2026, 7, 20), DateTime(2026, 7, 21)],
    valuesByDate: current,
    previousValuesByDate: previous,
    goal: goal,
  );

  test('averages only the days that have data', () {
    final trend = buildTrend(current: {DateTime(2026, 7, 21): 2000});

    expect(trend.current.loggedDayCount, 1);
    expect(trend.current.average, 2000);
    expect(trend.hasData, isTrue);
  });

  test('compares the period against the one before it', () {
    final trend = buildTrend(
      current: {DateTime(2026, 7, 21): 2200},
      previous: {DateTime(2026, 6, 21): 2000},
    );

    expect(trend.changeRatio, closeTo(1.1, 0.001));
    expect(trend.direction, TrendDirection.up);
  });

  test('has no direction without an earlier period to compare against', () {
    final trend = buildTrend(current: {DateTime(2026, 7, 21): 2200});

    expect(trend.changeRatio, isNull);
    expect(trend.direction, isNull);
  });

  test('a small change reads as flat rather than as movement', () {
    final trend = buildTrend(
      current: {DateTime(2026, 7, 21): 2020},
      previous: {DateTime(2026, 6, 21): 2000},
    );

    expect(trend.direction, TrendDirection.flat);
  });

  test('an area with no goal is never judged', () {
    final trend = buildTrend(current: {DateTime(2026, 7, 21): 74});

    expect(trend.adherence, isNull);
    expect(trend.isJudged, isFalse);
    expect(trend.isOnTrack, isFalse);
  });

  test('an area with a goal is judged by its average against it', () {
    final onTarget = buildTrend(current: {DateTime(2026, 7, 21): 2000}, goal: 2000);
    final off = buildTrend(current: {DateTime(2026, 7, 21): 900}, goal: 2000);

    expect(onTarget.adherence, GoalAdherence.met);
    expect(onTarget.isOnTrack, isTrue);
    expect(off.adherence, GoalAdherence.off);
  });

  test('a goal area with no data is not judged either', () {
    final trend = buildTrend(goal: 2000);

    expect(trend.isJudged, isFalse);
  });

  test('the verdict escalates as fewer areas hold their goal', () {
    expect(TrendsVerdict.forOnTrackRatio(1), TrendsVerdict.onTrack);
    expect(TrendsVerdict.forOnTrackRatio(2 / 3), TrendsVerdict.mixed);
    expect(TrendsVerdict.forOnTrackRatio(1 / 3), TrendsVerdict.offTrack);
    expect(TrendsVerdict.onTrack.adherence, GoalAdherence.met);
    expect(TrendsVerdict.offTrack.adherence, GoalAdherence.off);
  });
}
