import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

class DailyWater extends Equatable {
  const DailyWater({required this.entries});

  final List<WaterLog> entries;

  double get totalMl => entries.fold(0, (sum, entry) => sum + entry.amountMl);

  @override
  List<Object?> get props => [entries];
}
