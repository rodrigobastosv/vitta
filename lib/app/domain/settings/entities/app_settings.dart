import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:vitta/app/core/units/unit_system.dart';

class AppSettings extends Equatable {
  const AppSettings({this.locale, this.themeMode = ThemeMode.system, this.unitSystem = UnitSystem.metric});

  final Locale? locale;
  final ThemeMode themeMode;
  final UnitSystem unitSystem;

  AppSettings copyWith({Locale? locale, ThemeMode? themeMode, UnitSystem? unitSystem}) =>
      AppSettings(locale: locale ?? this.locale, themeMode: themeMode ?? this.themeMode, unitSystem: unitSystem ?? this.unitSystem);

  @override
  List<Object?> get props => [locale, themeMode, unitSystem];
}
