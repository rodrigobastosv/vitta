// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Vitta';

  @override
  String get homeTagline => 'Seu companheiro de dieta e treino.';

  @override
  String get dietFeatureTitle => 'Dieta';

  @override
  String get dietFeatureSubtitle => 'Acompanhe refeições e atinja suas metas nutricionais';

  @override
  String get workoutFeatureTitle => 'Treino';

  @override
  String get workoutFeatureSubtitle => 'Planeje e registre seus treinos';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get themeSystemDefault => 'Padrão do sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get comingSoonTitle => 'Em breve';

  @override
  String get dietComingSoonMessage => 'O acompanhamento de dieta está a caminho.';

  @override
  String get workoutComingSoonMessage => 'O acompanhamento de treino está a caminho.';
}
