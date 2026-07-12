import 'package:equatable/equatable.dart';

class WaterLog extends Equatable {
  const WaterLog({required this.id, required this.loggedDate, required this.amountMl});

  final String id;
  final DateTime loggedDate;
  final double amountMl;

  @override
  List<Object?> get props => [id, loggedDate, amountMl];
}
