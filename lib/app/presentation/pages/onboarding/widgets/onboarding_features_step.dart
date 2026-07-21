import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_feature_row.dart';

class OnboardingFeaturesStep extends StatelessWidget {
  const OnboardingFeaturesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = [
      (Icons.restaurant_outlined, VTColors.coral, l10n.dietFeatureTitle, l10n.dietFeatureSubtitle),
      (Icons.fitness_center_outlined, VTColors.green, l10n.workoutFeatureTitle, l10n.workoutFeatureSubtitle),
      (Icons.water_drop_outlined, VTColors.water, l10n.waterFeatureTitle, l10n.waterFeatureSubtitle),
      (Icons.bedtime_outlined, VTColors.sleep, l10n.sleepFeatureTitle, l10n.sleepFeatureSubtitle),
      (Icons.monitor_weight_outlined, VTColors.success, l10n.bodyWeightFeatureTitle, l10n.bodyWeightFeatureSubtitle),
      (Icons.checklist_rounded, VTColors.macroCarbs, l10n.reminderFeatureTitle, l10n.reminderFeatureSubtitle),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.l),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const VTGap.l(),
          Text(l10n.onboardingFeaturesTitle, style: VTTextStyles.headline(context)),
          const VTGap.l(),
          for (final (index, feature) in features.indexed) ...[
            VTAppearEffect(
              index: index,
              child: OnboardingFeatureRow(icon: feature.$1, accent: feature.$2, title: feature.$3, subtitle: feature.$4),
            ),
            if (index < features.length - 1) const VTGap.m(),
          ],
          const VTGap.l(),
        ],
      ),
    );
  }
}
