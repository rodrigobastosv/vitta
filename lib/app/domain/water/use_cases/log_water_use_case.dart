import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/water/water_repository.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

class LogWaterUseCase {
  LogWaterUseCase({required this._waterRepository});

  final WaterRepository _waterRepository;

  Future<Result<VTError, WaterLog>> call({required DateTime loggedDate, required double amountMl}) =>
      _waterRepository.logWater(loggedDate: loggedDate, amountMl: amountMl);
}
