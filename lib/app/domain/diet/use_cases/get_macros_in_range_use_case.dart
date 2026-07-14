import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

class GetMacrosInRangeUseCase {
  GetMacrosInRangeUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, Map<DateTime, DailyMacros>>> call({required DateTime from, required DateTime to}) =>
      _dietRepository.getMacrosInRange(from: from, to: to);
}
