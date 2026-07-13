import 'package:flutter/material.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_presentation_event.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/save_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';

class AppCubit extends PresentationCubit<AppSettings, AppPresentationEvent> {
  AppCubit({required GetAppSettingsUseCase getAppSettingsUseCase, required this._saveAppSettingsUseCase}) : super(getAppSettingsUseCase());

  final SaveAppSettingsUseCase _saveAppSettingsUseCase;

  void changeLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
    _saveAppSettingsUseCase(state);
  }

  void useSystemLocale() {
    emit(AppSettings(themeMode: state.themeMode, unitSystem: state.unitSystem));
    _saveAppSettingsUseCase(state);
  }

  void changeThemeMode(ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
    _saveAppSettingsUseCase(state);
  }

  void changeUnitSystem(UnitSystem unitSystem) {
    emit(state.copyWith(unitSystem: unitSystem));
    _saveAppSettingsUseCase(state);
  }
}
