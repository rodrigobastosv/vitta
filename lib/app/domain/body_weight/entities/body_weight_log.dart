import 'package:equatable/equatable.dart';

class BodyWeightLog extends Equatable {
  const BodyWeightLog({required this.id, required this.loggedDate, required this.weightKg, required this.createdAt});

  factory BodyWeightLog.fromMap(Map<String, dynamic> row) => BodyWeightLog(
    id: row['id'] as String,
    loggedDate: DateTime.parse(row['logged_date'] as String),
    weightKg: (row['weight_kg'] as num).toDouble(),
    createdAt: DateTime.parse(row['created_at'] as String),
  );

  final String id;
  final DateTime loggedDate;
  final double weightKg;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, loggedDate, weightKg, createdAt];
}
