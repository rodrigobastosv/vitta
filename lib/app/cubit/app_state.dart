import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:vitta/app/core/units/unit_system.dart';

class AppState extends Equatable {
  const AppState({this.locale, this.themeMode = ThemeMode.system, this.unitSystem = UnitSystem.metric});

  final Locale? locale;
  final ThemeMode themeMode;
  final UnitSystem unitSystem;

  @override
  List<Object?> get props => [locale, themeMode, unitSystem];
}
