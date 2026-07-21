import 'package:vitta/app/data/sleep/sleep_repository.dart';

class GetSleepLastSyncedUseCase {
  GetSleepLastSyncedUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  DateTime? call() => _sleepRepository.getLastSyncedAt();
}
