import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';

// Device-local like the diet goals it derives, not a Supabase table: it is a
// preference about how targets are calculated, and the numbers it produces
// (MacroGoals) are already stored the same way.
class BodyProfileLocalDataSource {
  BodyProfileLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _heightCmKey = 'bodyProfile.heightCm';
  static const _objectiveKey = 'bodyProfile.objective';

  BodyProfile getProfile() => BodyProfile(
    heightCm: _localStorageService.get<double>(_heightCmKey),
    objective: FitnessObjective.fromWireValue(_localStorageService.get<String>(_objectiveKey)),
  );

  Future<void> saveProfile(BodyProfile profile) async {
    final heightCm = profile.heightCm;
    if (heightCm != null) {
      await _localStorageService.put(_heightCmKey, heightCm);
    }
    final objective = profile.objective;
    if (objective != null) {
      await _localStorageService.put(_objectiveKey, objective.wireValue);
    }
  }
}
