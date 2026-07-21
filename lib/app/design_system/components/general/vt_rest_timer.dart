import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTRestTimer extends StatelessWidget {
  const VTRestTimer({required this.remaining, required this.progress, required this.onExtend, required this.onSkip, this.label, super.key});

  final Duration remaining;
  final double progress;
  final VoidCallback onExtend;
  final VoidCallback onSkip;
  final String? label;

  String get _formatted {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ink = VTColors.inkOn(VTColors.green);
    return DecoratedBox(
      decoration: const BoxDecoration(color: VTColors.green, borderRadius: VTRadius.borderRadiusL),
      child: Column(
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.s, VTSpacing.s, VTSpacing.s),
            child: Row(
              children: [
                Text(
                  _formatted,
                  style: VTTextStyles.title(context).copyWith(color: ink, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
                const VTGap.m(),
                Expanded(
                  child: Text(
                    label ?? l10n.workoutRestTimerLabel,
                    style: VTTextStyles.caption(context).copyWith(color: ink.withValues(alpha: 0.85)),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onExtend,
                  style: TextButton.styleFrom(foregroundColor: ink),
                  child: Text(l10n.workoutRestExtendAction),
                ),
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(foregroundColor: ink),
                  child: Text(l10n.workoutRestSkipAction),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            child: LinearProgressIndicator(value: progress, minHeight: 4, color: ink, backgroundColor: ink.withValues(alpha: 0.24)),
          ),
        ],
      ),
    );
  }
}
