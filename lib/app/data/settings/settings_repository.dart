import 'package:vitta/app/data/settings/settings_local_datasource.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';

class SettingsRepository {
  SettingsRepository({required this._settingsLocalDataSource});

  final SettingsLocalDataSource _settingsLocalDataSource;

  AppSettings getSettings() => AppSettings(
    locale: _settingsLocalDataSource.getLocale(),
    themeMode: _settingsLocalDataSource.getThemeMode(),
    unitSystem: _settingsLocalDataSource.getUnitSystem(),
  );

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsLocalDataSource.saveLocale(settings.locale);
    await _settingsLocalDataSource.saveThemeMode(settings.themeMode);
    await _settingsLocalDataSource.saveUnitSystem(settings.unitSystem);
  }
}
