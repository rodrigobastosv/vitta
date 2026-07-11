import 'package:flutter/material.dart';
import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({required LocalStorageService localStorageService}) : _localStorageService = localStorageService;

  final LocalStorageService _localStorageService;

  static const _localeKey = 'settings.locale';
  static const _themeModeKey = 'settings.themeMode';

  Locale? getLocale() {
    final languageCode = _localStorageService.get<String>(_localeKey);
    return languageCode == null ? null : Locale(languageCode);
  }

  Future<void> saveLocale(Locale? locale) =>
      locale == null ? _localStorageService.delete(_localeKey) : _localStorageService.put(_localeKey, locale.languageCode);

  ThemeMode getThemeMode() {
    final name = _localStorageService.get<String>(_themeModeKey);
    return ThemeMode.values.firstWhere((mode) => mode.name == name, orElse: () => ThemeMode.system);
  }

  Future<void> saveThemeMode(ThemeMode themeMode) => _localStorageService.put(_themeModeKey, themeMode.name);
}
