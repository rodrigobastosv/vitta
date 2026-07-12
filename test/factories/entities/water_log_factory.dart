import 'package:vitta/app/domain/water/entities/water_log.dart';

abstract class WaterLogFactory {
  static WaterLog build({String id = 'water-log-1', DateTime? loggedDate, double amountMl = 250}) =>
      WaterLog(id: id, loggedDate: loggedDate ?? DateTime(2026, 7, 11), amountMl: amountMl);
}
