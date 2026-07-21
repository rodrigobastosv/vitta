import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

abstract class BodyWeightLogFactory {
  static BodyWeightLog build({String id = 'bw-1', DateTime? loggedDate, double weightKg = 74, DateTime? createdAt}) =>
      BodyWeightLog(id: id, loggedDate: loggedDate ?? DateTime(2026, 7, 18), weightKg: weightKg, createdAt: createdAt ?? DateTime(2026, 7, 18, 8));
}
