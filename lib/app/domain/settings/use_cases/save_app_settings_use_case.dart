import 'package:vitta/app/data/settings/settings_repository.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';

class SaveAppSettingsUseCase {
  SaveAppSettingsUseCase({required this._settingsRepository});

  final SettingsRepository _settingsRepository;

  Future<void> call(AppSettings settings) => _settingsRepository.saveSettings(settings);
}
