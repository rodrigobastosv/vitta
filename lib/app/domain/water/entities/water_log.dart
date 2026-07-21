import 'package:equatable/equatable.dart';

class WaterLog extends Equatable {
  const WaterLog({required this.id, required this.loggedDate, required this.amountMl});

  factory WaterLog.fromMap(Map<String, dynamic> row) =>
      WaterLog(id: row['id'] as String, loggedDate: DateTime.parse(row['logged_date'] as String), amountMl: (row['amount_ml'] as num).toDouble());

  final String id;
  final DateTime loggedDate;
  final double amountMl;

  @override
  List<Object?> get props => [id, loggedDate, amountMl];
}
