import 'package:vitta/app/core/services/purchases/premium_period.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

// The nutrientLabel/dietModalityLabel pattern: the period is a plain enum in
// core/services/, and its wording lives here so nothing below presentation
// imports AppLocalizations.
String premiumPeriodLabel(AppLocalizations l10n, PremiumPeriod period) => switch (period) {
  .weekly => l10n.premiumPeriodWeekly,
  .monthly => l10n.premiumPeriodMonthly,
  .twoMonth => l10n.premiumPeriodTwoMonth,
  .threeMonth => l10n.premiumPeriodThreeMonth,
  .sixMonth => l10n.premiumPeriodSixMonth,
  .annual => l10n.premiumPeriodAnnual,
  .lifetime => l10n.premiumPeriodLifetime,
};
