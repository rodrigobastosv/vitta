import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class DailySleep extends Equatable {
  const DailySleep({required this.entries});

  final List<SleepLog> entries;

  Duration get totalDuration => entries.fold(Duration.zero, (sum, entry) => sum + entry.duration);

  double get totalHours => totalDuration.inMinutes / 60;

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
