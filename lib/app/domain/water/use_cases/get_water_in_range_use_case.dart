import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/water/water_repository.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

class GetWaterInRangeUseCase {
  GetWaterInRangeUseCase({required this._waterRepository});

  final WaterRepository _waterRepository;

  Future<Result<VTError, Map<DateTime, DailyWater>>> call({required DateTime from, required DateTime to}) =>
      _waterRepository.getWaterInRange(from: from, to: to);
}
