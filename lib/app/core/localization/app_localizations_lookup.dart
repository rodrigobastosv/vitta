import 'dart:ui';

import 'package:vitta/l10n/arb/app_localizations.dart';

AppLocalizations localizationsFor(Locale? locale) {
  final preferred = locale ?? PlatformDispatcher.instance.locale;
  final isSupported = AppLocalizations.supportedLocales.any((supported) => supported.languageCode == preferred.languageCode);
  return lookupAppLocalizations(isSupported ? Locale(preferred.languageCode) : const Locale('en'));
}
