import 'package:vitta/l10n/arb/app_localizations.dart';

enum TrendRange {
  week(7),
  month(30),
  quarter(90);

  const TrendRange(this.days);

  final int days;

  String getLabel(AppLocalizations l10n) => l10n.dietTrendRangeDays(days);
}
