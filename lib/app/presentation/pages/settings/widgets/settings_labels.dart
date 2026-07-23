import 'package:flutter/material.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String settingsLocaleLabel(Locale? locale, AppLocalizations l10n) => switch (locale?.languageCode) {
  'en' => l10n.languageEnglish,
  'pt' => l10n.languagePortuguese,
  _ => l10n.languageSystemDefault,
};

extension SettingsThemeModeLabel on ThemeMode {
  String label(AppLocalizations l10n) => switch (this) {
    .system => l10n.themeSystemDefault,
    .light => l10n.themeLight,
    .dark => l10n.themeDark,
  };
}

extension SettingsUnitSystemLabel on UnitSystem {
  String label(AppLocalizations l10n) => switch (this) {
    .metric => l10n.unitSystemMetric,
    .imperial => l10n.unitSystemImperial,
  };
}
