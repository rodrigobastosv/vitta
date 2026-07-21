import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/use_cases/get_macro_goals_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_presentation_event.dart';

class MacroGoalsCubit extends PresentationCubit<MacroGoals, MacroGoalsPresentationEvent> {
  MacroGoalsCubit({required GetMacroGoalsUseCase getMacroGoalsUseCase, required this._saveMacroGoalsUseCase}) : super(getMacroGoalsUseCase());

  final SaveMacroGoalsUseCase _saveMacroGoalsUseCase;

  Future<void> saveGoals(MacroGoals goals) async {
    emit(goals);
    await _saveMacroGoalsUseCase(goals);
    Log.action('macro_goals_saved');
  }
}
