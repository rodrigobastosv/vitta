import 'package:vitta/app/data/water/water_repository.dart';

class GetWaterGoalUseCase {
  GetWaterGoalUseCase({required this._waterRepository});

  final WaterRepository _waterRepository;

  double call() => _waterRepository.getDailyGoalMl();
}
