import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class GetMacroGoalsUseCase {
  GetMacroGoalsUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  MacroGoals call() => _dietRepository.getMacroGoals();
}
