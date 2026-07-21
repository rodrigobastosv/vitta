import 'package:vitta/l10n/arb/app_localizations.dart';

String formatSleepDuration(AppLocalizations l10n, Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0 && minutes > 0) {
    return l10n.sleepDurationLabel(hours, minutes);
  }
  if (hours > 0) {
    return l10n.sleepHoursOnly(hours);
  }
  return l10n.sleepMinutesOnly(minutes);
}
