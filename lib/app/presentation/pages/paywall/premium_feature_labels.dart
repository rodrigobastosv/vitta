import 'package:flutter/material.dart';
import 'package:vitta/app/domain/premium/entities/premium_feature.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String premiumFeatureTitle(AppLocalizations l10n, PremiumFeature feature) => switch (feature) {
  .mealScan => l10n.premiumFeatureMealScanTitle,
  .nutritionLabelScan => l10n.premiumFeatureNutritionLabelScanTitle,
};

String premiumFeatureSubtitle(AppLocalizations l10n, PremiumFeature feature) => switch (feature) {
  .mealScan => l10n.premiumFeatureMealScanSubtitle,
  .nutritionLabelScan => l10n.premiumFeatureNutritionLabelScanSubtitle,
};

IconData premiumFeatureIcon(PremiumFeature feature) => switch (feature) {
  .mealScan => Icons.photo_camera_outlined,
  .nutritionLabelScan => Icons.document_scanner_outlined,
};
