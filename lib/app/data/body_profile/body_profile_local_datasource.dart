import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
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
  static const _sexKey = 'bodyProfile.sex';
  static const _birthDateKey = 'bodyProfile.birthDate';
  static const _activityLevelKey = 'bodyProfile.activityLevel';

  BodyProfile getProfile() {
    final birthDateMillis = _localStorageService.get<int>(_birthDateKey);
    return BodyProfile(
      heightCm: _localStorageService.get<double>(_heightCmKey),
      objective: FitnessObjective.fromWireValue(_localStorageService.get<String>(_objectiveKey)),
      sex: BiologicalSex.fromWireValue(_localStorageService.get<String>(_sexKey)),
      birthDate: birthDateMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(birthDateMillis),
      activityLevel: ActivityLevel.fromWireValue(_localStorageService.get<String>(_activityLevelKey)),
    );
  }

  Future<void> saveProfile(BodyProfile profile) async {
    final heightCm = profile.heightCm;
    if (heightCm != null) {
      await _localStorageService.put(_heightCmKey, heightCm);
    }
    final objective = profile.objective;
    if (objective != null) {
      await _localStorageService.put(_objectiveKey, objective.wireValue);
    }
    final sex = profile.sex;
    if (sex != null) {
      await _localStorageService.put(_sexKey, sex.wireValue);
    }
    final birthDate = profile.birthDate;
    if (birthDate != null) {
      await _localStorageService.put(_birthDateKey, birthDate.millisecondsSinceEpoch);
    }
    final activityLevel = profile.activityLevel;
    if (activityLevel != null) {
      await _localStorageService.put(_activityLevelKey, activityLevel.wireValue);
    }
  }
}
