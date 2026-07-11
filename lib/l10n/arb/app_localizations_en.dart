// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vitta';

  @override
  String get homeTagline => 'Your companion for diet and training.';

  @override
  String get dietFeatureTitle => 'Diet';

  @override
  String get dietFeatureSubtitle => 'Track meals and reach your nutrition goals';

  @override
  String get workoutFeatureTitle => 'Workout';

  @override
  String get workoutFeatureSubtitle => 'Plan and log your training sessions';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get themeSystemDefault => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get dietComingSoonMessage => 'Diet tracking is on its way.';

  @override
  String get workoutComingSoonMessage => 'Workout tracking is on its way.';
}
