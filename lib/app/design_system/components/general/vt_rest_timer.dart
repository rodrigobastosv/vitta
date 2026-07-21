import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTRestTimer extends StatelessWidget {
  const VTRestTimer({
    required this.remaining,
    required this.progress,
    required this.onExtend,
    required this.onShorten,
    required this.onSkip,
    this.label,
    this.onConfigure,
    super.key,
  });

  static const Duration _urgentFrom = Duration(seconds: 10);

  final Duration remaining;
  final double progress;
  final VoidCallback onExtend;
  final VoidCallback onShorten;
  final VoidCallback onSkip;
  final String? label;
  final VoidCallback? onConfigure;

  String get _formatted {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get _isUrgent => remaining <= _urgentFrom;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final background = _isUrgent ? VTColors.coral : VTColors.green;
    final ink = VTColors.inkOn(background);
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: VTRadius.borderRadiusL),
      child: Column(
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.s, VTSpacing.s, VTSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      Text(
                        _formatted,
                        style: VTTextStyles.headline(context).copyWith(color: ink, fontFeatures: const [FontFeature.tabularFigures()]),
                      ),
                      Text(
                        label ?? l10n.workoutRestTimerLabel,
                        style: VTTextStyles.caption(context).copyWith(color: ink.withValues(alpha: 0.85)),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: onShorten, icon: const Icon(Icons.remove), color: ink, tooltip: l10n.workoutRestShortenAction),
                IconButton(onPressed: onExtend, icon: const Icon(Icons.add), color: ink, tooltip: l10n.workoutRestExtendAction),
                if (onConfigure != null) IconButton(onPressed: onConfigure, icon: const Icon(Icons.tune), color: ink, tooltip: l10n.workoutRestConfigureAction),
                const VTGap.xs(),
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
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(seconds: 1),
              builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 5, color: ink, backgroundColor: ink.withValues(alpha: 0.24)),
            ),
          ),
        ],
      ),
    );
  }
}
