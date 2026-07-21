import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_duration_format.dart';

class SleepDurationHero extends StatelessWidget {
  const SleepDurationHero({required this.duration, required this.isValid, super.key});

  final Duration duration;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = isValid ? VTColors.sleep : VTColors.warningStrong;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: VTSpacing.m),
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.10), borderRadius: VTRadius.borderRadiusL),
      child: Column(
        children: [
          Text(
            isValid ? formatSleepDuration(l10n, duration) : l10n.sleepInvalidRange,
            textAlign: .center,
            style: (isValid ? VTTextStyles.display(context) : VTTextStyles.bodyStrong(context)).copyWith(color: accent, fontWeight: .w700),
          ),
          if (isValid) ...[
            const VTGap.xs(),
            Text(l10n.sleepLogDurationHint, style: VTTextStyles.overline(context)),
          ],
        ],
      ),
    );
  }
}
