import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

class GetCachedDailyMacrosUseCase {
  GetCachedDailyMacrosUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  DailyMacros? call({required DateTime date}) => _dietRepository.cachedDailyMacros(date: date);
}
