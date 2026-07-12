import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

class GetDailyMacrosUseCase {
  GetDailyMacrosUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, DailyMacros>> call({required DateTime date}) => _dietRepository.getDailyMacros(date: date);
}
