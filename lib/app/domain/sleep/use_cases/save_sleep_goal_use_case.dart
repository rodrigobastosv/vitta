import 'package:vitta/app/data/sleep/sleep_repository.dart';

class SaveSleepGoalUseCase {
  SaveSleepGoalUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  Future<void> call({required double goalHours}) => _sleepRepository.saveDurationGoalHours(goalHours);
}
