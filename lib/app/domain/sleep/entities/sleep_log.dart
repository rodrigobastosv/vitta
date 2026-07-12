import 'package:equatable/equatable.dart';

class SleepLog extends Equatable {
  const SleepLog({required this.id, required this.loggedDate, required this.bedTime, required this.wakeTime, this.qualityRating});

  final String id;
  final DateTime loggedDate;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int? qualityRating;

  Duration get duration => wakeTime.difference(bedTime);

  @override
  List<Object?> get props => [id, loggedDate, bedTime, wakeTime, qualityRating];
}
