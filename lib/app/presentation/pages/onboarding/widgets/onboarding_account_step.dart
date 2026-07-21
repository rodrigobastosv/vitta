import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class OnboardingAccountStep extends StatelessWidget {
  const OnboardingAccountStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.l),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          VTAppearEffect(
            child: Container(
              width: 80,
              height: 80,
              alignment: .center,
              decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: .circle),
              child: Icon(Icons.cloud_done_outlined, size: 40, color: colorScheme.onPrimaryContainer),
            ),
          ),
          const VTGap.xl(),
          VTAppearEffect(
            index: 1,
            child: Text(l10n.onboardingAccountTitle, style: VTTextStyles.headline(context), textAlign: .center),
          ),
          const VTGap.m(),
          VTAppearEffect(
            index: 2,
            child: Text(
              l10n.onboardingAccountBenefitMessage,
              style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }
}
