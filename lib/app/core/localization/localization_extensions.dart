import 'package:flutter/material.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension BuildContextLocalizationExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  MaterialLocalizations get materialLocalizations => MaterialLocalizations.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
