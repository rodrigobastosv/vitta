import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';

/// How many nights landed on each 1-5 rating across a window.
///
/// Only rated nights are counted: the rating is optional, so an unrated night
/// is missing data, not a bad night.
class SleepQualitySplit extends Equatable {
  const SleepQualitySplit({required this.nightsByRating});

  factory SleepQualitySplit.fromDays(Iterable<DailySleep> days) {
    final nightsByRating = <int, int>{};
    for (final day in days) {
      for (final entry in day.entries) {
        if (entry.qualityRating case final rating?) {
          nightsByRating[rating] = (nightsByRating[rating] ?? 0) + 1;
        }
      }
    }
    return SleepQualitySplit(nightsByRating: nightsByRating);
  }

  final Map<int, int> nightsByRating;

  static const ratings = [1, 2, 3, 4, 5];

  int get ratedNightCount => nightsByRating.values.fold(0, (sum, count) => sum + count);

  bool get hasData => ratedNightCount > 0;

  int nightsAt(int rating) => nightsByRating[rating] ?? 0;

  double shareAt(int rating) => ratedNightCount == 0 ? 0 : nightsAt(rating) / ratedNightCount;

  @override
  List<Object?> get props => [nightsByRating];
}
