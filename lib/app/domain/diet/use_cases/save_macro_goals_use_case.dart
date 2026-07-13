import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class SaveMacroGoalsUseCase {
  SaveMacroGoalsUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<void> call(MacroGoals goals) => _dietRepository.saveMacroGoals(goals);
}
