import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;

  static const _localeKey = 'locale';
  static const _themeModeKey = 'themeMode';

  Locale? getLocale() {
    final languageCode = _box.get(_localeKey) as String?;
    return languageCode == null ? null : Locale(languageCode);
  }

  Future<void> saveLocale(Locale? locale) =>
      locale == null ? _box.delete(_localeKey) : _box.put(_localeKey, locale.languageCode);

  ThemeMode getThemeMode() {
    final name = _box.get(_themeModeKey) as String?;
    return ThemeMode.values.firstWhere((mode) => mode.name == name, orElse: () => ThemeMode.system);
  }

  Future<void> saveThemeMode(ThemeMode themeMode) => _box.put(_themeModeKey, themeMode.name);
}
