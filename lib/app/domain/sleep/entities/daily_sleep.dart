import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

/// One date's sleep. Usually a single night, but the schema doesn't stop a user
/// from logging a nap too, so durations are summed rather than assuming one log.
class DailySleep extends Equatable {
  const DailySleep({required this.entries});

  final List<SleepLog> entries;

  Duration get totalDuration => entries.fold(Duration.zero, (sum, entry) => sum + entry.duration);

  double get totalHours => totalDuration.inMinutes / 60;

  /// The mean of the nights that were actually rated — the field is optional,
  /// so a day can have sleep logged and no rating at all.
  double? get averageQuality {
    final ratings = [for (final entry in entries) ?entry.qualityRating];
    if (ratings.isEmpty) {
      return null;
    }
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  @override
  List<Object?> get props => [entries];
}
