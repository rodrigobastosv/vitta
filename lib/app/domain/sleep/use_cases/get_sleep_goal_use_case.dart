import 'package:vitta/app/data/sleep/sleep_repository.dart';

class GetSleepGoalUseCase {
  GetSleepGoalUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  double call() => _sleepRepository.getDurationGoalHours();
}
