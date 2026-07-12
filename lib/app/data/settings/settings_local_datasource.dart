import 'package:flutter/material.dart';
import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/core/units/unit_system.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _localeKey = 'settings.locale';
  static const _themeModeKey = 'settings.themeMode';
  static const _unitSystemKey = 'settings.unitSystem';

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

  UnitSystem getUnitSystem() {
    final wireValue = _localStorageService.get<String>(_unitSystemKey);
    return wireValue == null ? UnitSystem.metric : UnitSystem.fromWireValue(wireValue);
  }

  Future<void> saveUnitSystem(UnitSystem unitSystem) => _localStorageService.put(_unitSystemKey, unitSystem.wireValue);
}
