import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';

class GetSleepInRangeUseCase {
  GetSleepInRangeUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  Future<Result<VTError, Map<DateTime, DailySleep>>> call({required DateTime from, required DateTime to}) =>
      _sleepRepository.getSleepInRange(from: from, to: to);
}
