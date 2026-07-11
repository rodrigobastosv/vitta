import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_state.dart';
import 'package:vitta/app/data/settings/settings_local_datasource.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({required SettingsLocalDataSource settingsLocalDataSource})
    : _settingsLocalDataSource = settingsLocalDataSource,
      super(
        AppState(
          locale: settingsLocalDataSource.getLocale(),
          themeMode: settingsLocalDataSource.getThemeMode(),
          unitSystem: settingsLocalDataSource.getUnitSystem(),
        ),
      );

  final SettingsLocalDataSource _settingsLocalDataSource;

  void changeLocale(Locale locale) {
    emit(AppState(locale: locale, themeMode: state.themeMode, unitSystem: state.unitSystem));
    _settingsLocalDataSource.saveLocale(locale);
  }

  void useSystemLocale() {
    emit(AppState(themeMode: state.themeMode, unitSystem: state.unitSystem));
    _settingsLocalDataSource.saveLocale(null);
  }

  void changeThemeMode(ThemeMode themeMode) {
    emit(AppState(locale: state.locale, themeMode: themeMode, unitSystem: state.unitSystem));
    _settingsLocalDataSource.saveThemeMode(themeMode);
  }

  void changeUnitSystem(UnitSystem unitSystem) {
    emit(AppState(locale: state.locale, themeMode: state.themeMode, unitSystem: unitSystem));
    _settingsLocalDataSource.saveUnitSystem(unitSystem);
  }
}
