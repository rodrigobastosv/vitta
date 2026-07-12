import 'package:vitta/app/data/settings/settings_repository.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';

class GetAppSettingsUseCase {
  GetAppSettingsUseCase({required this._settingsRepository});

  final SettingsRepository _settingsRepository;

  AppSettings call() => _settingsRepository.getSettings();
}
