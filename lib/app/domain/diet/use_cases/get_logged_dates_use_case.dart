import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';

class GetLoggedDatesUseCase {
  GetLoggedDatesUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, Set<DateTime>>> call({required DateTime from, required DateTime to}) =>
      _dietRepository.getLoggedDates(from: from, to: to);
}
