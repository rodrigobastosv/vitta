import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/water/water_repository.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

class GetDailyWaterUseCase {
  GetDailyWaterUseCase({required WaterRepository waterRepository}) : _waterRepository = waterRepository;

  final WaterRepository _waterRepository;

  Future<Result<VTError, DailyWater>> call({required DateTime date}) => _waterRepository.getDailyWater(date: date);
}
